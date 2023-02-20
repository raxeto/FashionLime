class User < ActiveRecord::Base

  GUEST_USERNAME_PREFIX = 'guest'.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Attributes not stored in DB
  # validate_email_presence - Use this to skip email validaiton for guest users
  # email_o - a phony attr so that we can workaround bootstrap_form_for's required field
  attr_accessor :allow_duplicate_username, :validate_email_presence, :email_o,
      :password_o, :allow_guest_username, :allow_empty_password
  enum status: { active: 1, not_active: 2 }

  # Scopes
  scope :with_emails, -> { where.not(email: [nil, '']) }
  scope :subscribed_for_promotions, -> { with_emails.where(email_promotions: true) }
  scope :admins, -> { joins(:user_roles).where("user_roles.role": "admin") }
  scope :guests, -> { joins(:user_roles).where("user_roles.role": "guest") }

  # Relations
  has_many    :user_roles, dependent: :destroy
  has_many    :addresses, as: :owner, dependent: :destroy
  has_one     :merchant_user, dependent: :destroy
  has_one     :merchant, :through => :merchant_user
  has_one     :cart, dependent: :destroy
  has_many    :orders
  has_many    :merchant_orders, :through => :orders
  has_many    :merchant_order_returns
  has_many    :outfits
  has_many    :contact_inquiries
  belongs_to  :profile, dependent: :destroy
  has_attached_file :avatar,
    styles: { original: ["512x512#"], medium: ["320x320#"], thumb: ["120x120#"] },
    url: Modules::SeoFriendlyAttachment.url,
    default_url: Conf.user.avatar_default_path

  before_post_process :rename_file_name

  # Callbacks
  before_save  :update_url_path
  after_create :create_empty_cart, :create_user_profile
  after_commit :update_es_indexes, on: [:update]
  after_commit :open_graph_clear_cache, on: [:update]
  after_validation :transfer_optional_email_errors, on: [:update, :create]

  # Validations
  validates_presence_of :username
  validates :username, uniqueness: { case_sensitive: false },   if: :validate_unique_username?
  validates_format_of :username, with: /\A[^\/\s\\]+\Z/i
  validate :non_guest_username, unless: :skip_non_guest_username_validation?
  validates_offensive_words_in :username
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :avatar, :less_than => Conf.attachment.max_file_size

  validates :email, email: true, allow_blank: true
  validates_presence_of :email, if: :merchant?

  def contact_name
    if self.first_name.present?
      self.first_name
    elsif self.last_name.present?
      self.last_name
    else
      self.username
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.create_guest_user
    params = {
      email_promotions: false,
      allow_duplicate_username: false,
      allow_empty_password: true,
      allow_guest_username: true,
      username: self.create_unique_guest_username
    }
    user = self.create(params)

    unless user.valid?
      Rails.logger.error "Failed to save user with params: #{params}! Errors: #{user.errors.full_messages}"
      params[:username] = 'guest'
      params[:allow_duplicate_username] = true
      user = User.create(params)
    end

    user.assign_guest_role
    return user
  end

  def self.create_unique_guest_username
    generator = Modules::RandomNumberGenerator.new(
        prefix: GUEST_USERNAME_PREFIX,
        initial_length: 6)
    generator.generate(
        Proc.new { |candidate| !User.exists?(username: candidate) },
        UserRole.where(role: 'guest').count)
  end

  def self.transfer_guest_data(from_user_id, to_user_id)
    from_user = User.find_by_id(from_user_id)
    to_user = User.find_by_id(to_user_id)

    return if from_user.nil? || to_user.nil?

    # Transfer the cart.
    to_user.cart.transfer_from(from_user.cart)

    # Transfer any filled properties due to an order
    # to_user.fill_empty_attributes_from(from_user)

    # Transfer any past orders, made as a guest
    # to_user.transfer_orders(from_user)

    # Transfer addresses
    # to_user.assign_addresses(from_user.addresses)

    # Transfer outfits
    to_user.transfer_outfits(from_user.outfits)

    # Transfer inquiries
    # to_user.transfer_inquiries(from_user.contact_inquiries)

    RegisteredUserGuest.create(user_id: to_user_id, guest_id: from_user_id)
  end

  def assign_addresses(new_addresses)
    return if new_addresses.blank?

    ActiveRecord::Base.transaction do
      success = true
      new_addresses.each do |a|
        begin
          unless a.update_attributes(owner_id: id)
            success = false
          end
        rescue ActiveRecord::ActiveRecordError
          success = false
        end
        unless success
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def transfer_outfits(new_outfits)
    return if new_outfits.blank?

    ActiveRecord::Base.transaction do
      success = true
      new_outfits.each do |o|
        begin
          unless o.update_attributes(user_id: id, profile_id: profile_id)
            success = false
          end
        rescue ActiveRecord::ActiveRecordError
          success = false
        end
        unless success
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def transfer_inquiries(new_inquiries)
    return if new_inquiries.blank?

    ActiveRecord::Base.transaction do
      success = true
      new_inquiries.each do |o|
        begin
          unless o.update_attributes(user_id: id)
            success = false
          end
        rescue ActiveRecord::ActiveRecordError
          success = false
        end
        unless success
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def fill_empty_attributes_from(source_user)
    user_changed = false
    source_user.attributes.each_pair do |name, value|
      if value.present? && self[name].blank?
        self[name] = value
        user_changed = true
      end
    end
    if user_changed
      save
    end
  end

  def transfer_orders(source_user)
    ActiveRecord::Base.transaction do
      success = true
      source_user.orders.each do |o|
        begin
          unless o.update_attributes(user_id: id)
            success = false
          end
        rescue ActiveRecord::ActiveRecordError
          success = false
        end
        unless success
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  SPECIAL_RIGHTS = [:admin, :guest, :merchant, :merchant_admin ]

  SPECIAL_RIGHTS.each do |right|
    define_method("#{right}?") do ||
      test_for_role("#{right}")
    end
  end

  SPECIAL_RIGHTS.each do |right|
    define_method("assign_#{right}_role") do ||
      assign_role("#{right}")
    end
  end

  # Regular users - not merchants, guests or admins
  def regular_user?
    user_roles.size == 0
  end

  def active_for_authentication?
    # prevent from guest users to sign in or sign up (we create them ourselves in the client_lib)
    super && self.active? && !self.guest?
  end

  def inactive_message
    guest? ? I18n.t('user.guests_cant_sign_in') : super
  end

  def assign_merchant_profile
    profile.destroy()
    p = Profile.find_or_create_by(owner: merchant_user.merchant)
    update_attributes(profile_id: p.id)
  end

  def is_empty_guest_user?
    return false unless guest?
    return false unless cart.empty?
    return false unless orders.empty?
    return false unless outfits.empty?
    # what about the rating?
    return true
  end

  protected

    def non_guest_username
      if username.downcase.start_with?(GUEST_USERNAME_PREFIX.downcase)
        errors.add(:username, I18n.t('user.guest_username_prefix'))
      end
    end

    def transfer_optional_email_errors
      unless self.errors[:email].empty?
        self.errors[:email_o] = self.errors[:email]
      end
    end

    def update_es_indexes
      if merchant.blank? && (did_attr_change?(:status) || did_attr_change?(:username))
        self.reload
        outfits.each do |outfit|
          # Update all outfits with this product
          Modules::DelayedJobs::EsIndexer.schedule('update_document', outfit)
          Modules::OutfitJsonBuilder.instance.refresh_outfit_cache(outfit.try(:id))
        end
      end
    end

    def open_graph_clear_cache
      if regular_user? && did_attr_change?(:avatar_updated_at)
        Modules::OpenGraph.clear_cached_pages(self)
      end
    end

    def test_for_role(role)
      user_roles.each do |user_role|
        if user_role.role == role
          return true
        end
      end

      return false
    end

    def assign_role(role)
      user_roles.create(role: role)
    end

    def validate_unique_username?
      return !allow_duplicate_username
    end

    def skip_non_guest_username_validation?
      return allow_guest_username.present?
    end

    def password_required?
      super && !allow_empty_password
    end

    def email_required?
      validate_email_presence
    end

    def create_user_profile
      p = Profile.create(owner: self)
      update_attributes(profile_id: p.id)
    end

    def update_url_path
      self.url_path = username.parameterize
      while User.where("url_path = ? and id != ?", self.url_path, self.id.to_i).exists? do
        self.url_path = self.url_path + "-#{Modules::RandLib.six_digits}"
      end
      true
    end

    def create_empty_cart
      create_cart()
    end

    def rename_file_name
      Modules::SeoFriendlyAttachment.set_file_name(self, avatar, "#{username.parameterize}-avatar")
    end
end

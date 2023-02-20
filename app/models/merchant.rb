class Merchant < ActiveRecord::Base

  include Elasticsearch::Model
  include Modules::EsIndexedModel

  settings do
    mappings dynamic: 'false' do
      indexes :name, analyzer: 'fashionlime_bg'
      # indexes :description, analyzer: 'bulgarian'
      indexes :created_at
      indexes :rating
      indexes :visible, index: :not_analyzed
    end
  end

  # Attributes
  enum status: { not_completed: 1, active: 2, deactivated: 3 }

  # Relations
  has_many :merchant_users
  has_many :users, through: :merchant_users
  accepts_nested_attributes_for :users

  has_many :merchant_product_api_mappings, dependent: :destroy
  has_many :outfits, :through => :users
  has_many :products
  has_many :product_collections
  has_many :articles, through: :products

  has_many :merchant_shipments
  accepts_nested_attributes_for :merchant_shipments
  has_many :available_shipments, -> { available.order(:price, :min_order_price) }, class_name: 'MerchantShipment'

  has_many :merchant_payment_types
  has_many :payment_types, :through => :merchant_payment_types

  has_many :available_merchant_payment_types, -> {
    available.joins(:payment_type).
    order("payment_types.order_index")
  }, class_name: 'MerchantPaymentType'

  has_many :merchant_orders
  accepts_nested_attributes_for :merchant_orders

  has_many :merchant_order_returns, :through => :merchant_orders
  has_many :size_charts
  has_many :merchant_settings
  has_one :profile, as: :owner

  # Scopes
  scope :collection_display, -> {
    includes(:products, :outfits)
  }

  # Use merchant validation while is not activated in order to save nested associations
  attr_accessor :skip_validation
  attr_accessor :agree_terms_of_use

  # Validations
  validates :name, presence: true, :unless => :skip_validation?
  validates :name, uniqueness: { case_sensitive: false }, :unless => :skip_validation?
  validates :return_policy, presence: true, on: :update, :unless => :skip_validation?
  validates :return_instructions, presence: true, on: :update, :unless => :skip_validation?
  validates :phone, presence: true, on: :update, :unless => :skip_validation?
  validate  :right_website_prefix, on: :update, :unless => :skip_validation?
  validate  :unique_url_path, on: :create, :unless => :skip_validation?
  validates_numericality_of :return_days, :greater_than_or_equal_to => Conf.merchant.return_days_min, :on => :update,  :unless => :skip_validation?
  validates :agree_terms_of_use, acceptance: true, :on => :update, :unless => :skip_validation?

  # Attachments
  has_attached_file :logo,
    styles: {  original: ["512x512#"], medium: ["320x320#"], thumb: ["120x120#"] },
    url: Modules::SeoFriendlyAttachment.url,
    default_url: Conf.merchant.logo_default_path

  before_post_process :rename_file_name

  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :logo, :less_than => Conf.attachment.max_file_size

  # Callbacks
  after_commit :update_es_indexes, on: [:update]
  after_commit :open_graph_clear_cache, on: [:update]
  after_commit :update_product_category_status_on_update, on: [:update]

  def active_articles
    articles.includes(:product, :size, :color).where(Article.available_clause)
  end

  def profile_id
    return profile.id
  end

  def available_payment_types
    available_merchant_payment_types.map { |mp| mp.payment_type }.sort_by { |p| p.order_index }.uniq
  end

  def self.es_search(query = '', count = nil, offset = nil, filters = [], sort_by = nil,
      all_words_should_match = false)
    es_query = Modules::ElasticSearchHelper.format_query(query, count, offset,
      filters, sort_by, ['name'], all_words_should_match)
    return Merchant.search(es_query).records.collection_display
  end

  def capped_name
    if self.name.size > Conf.merchant.capped_name_max_length
      return self.name[0...Conf.merchant.capped_name_max_length] + '...'
    end
    return self.name
  end

  def active_emails
    users.active.pluck(:email)
  end

  def setting_value(setting_key)
    merchant_settings.find_by_key(setting_key).try(:value)
  end

  def as_indexed_json(options={})
    json = self.as_json
    json[:visible] = active?
    return json
  end

  def has_missing_profile_info?
    # Put here any new fields that the existing merchants must fill out.
    phone.blank? || return_instructions.blank?
  end

  private

  def shipments_for_location(location_id)
    # TODO location
    available_shipments
  end

  def right_website_prefix
    if !website.blank? && !website.starts_with?("http://") && !website.starts_with?("https://")
      errors.add(:website, "уебсайтът трябва да започва с 'http://' или 'https://'")
    end
  end

  def unique_url_path
    self.url_path = name.parameterize
    if Merchant.where("url_path = ? and id != ?", self.url_path, self.id.to_i).exists?
      unless errors.include?(:name)
        errors.add(:name, "съществува търговец със сходно име")
      end
    end
  end

  def skip_validation?
    skip_validation
  end

  def open_graph_clear_cache
    if did_attr_change?(:logo_updated_at)
      Modules::OpenGraph.clear_cached_pages(self)
    end
  end

  def update_es_indexes
    if did_attr_change?(:status) || did_attr_change?(:name)
      # Be sure to reload the merchant, before updating the dependent models. This
      # was causing the outfits to not update properly.
      self.reload

      # Update the merchant's index
      Modules::DelayedJobs::EsIndexer.schedule('update_document', self)

      products.each do |product|
        # Update all products for this merchant
        Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
        Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id)
      end

      outfits.each do |outfit|
        # Update all outfits for this merchant
        Modules::DelayedJobs::EsIndexer.schedule('update_document', outfit)
        Modules::OutfitJsonBuilder.instance.refresh_outfit_cache(outfit.try(:id))
      end
    end
  end

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, logo, "#{name.parameterize}-logo")
  end

  def update_product_category_status_on_update
    if did_attr_change?(:status)
      categories = ProductCategory.where(:id => products.pluck(:product_category_id).uniq)
      categories.each do |c|
        c.update_status
      end
    end
  end

end

Modules::ElasticSearchHelper.setup_elastic_search_indexes(Merchant) if Rails.env.development?

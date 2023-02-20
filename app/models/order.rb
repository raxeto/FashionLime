class Order < ActiveRecord::Base

  include Modules::PublicUserModel

  # Attributes
  attr_accessor :user_address_id
  attr_accessor :agree_terms_of_use
  currency_accessor :total, :total_with_discount, :total_shipment, :total_with_shipment

  # Relations
  belongs_to :user

  has_one    :address, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many   :merchant_orders
  accepts_nested_attributes_for :merchant_orders, :reject_if => lambda { |p| p[:merchant_order_details_attributes].blank? }

  has_many :merchant_order_details, :through => :merchant_orders

  # Validations
  validates :user_first_name, presence: true
  validates :user_last_name, presence: true 
  validates :user_phone, presence: true 
  validates :user_email, email: true, presence: true
  validates :agree_terms_of_use, acceptance: true, on: :create

  # Callbacks
  after_create :add_user_info

  public

  def total
    # TODO ADD Total columns into the database
    merchant_orders.to_a.sum(&:total)
  end

  def total_with_discount
    merchant_orders.to_a.sum(&:total_with_discount)
  end

  def total_shipment
    merchant_orders.to_a.sum(&:shipment_price)
  end

  def total_with_shipment
    merchant_orders.to_a.sum(&:total_with_shipment)
  end

  # Check if the order contains at least one merchant order with payment type
  # that requires additional actions (like ePay/paypall buttons or bank transfer)
  def has_additional_payment?
    merchant_orders.each do |mo|
      if mo.has_additional_payment?
        return true
      end
    end
    return false
  end

  def is_ready_for_payment?
    merchant_orders.each do |mo|
      unless mo.is_ready_for_payment?
        return false
      end
    end
    return true
  end

  def is_payment_info_valid?
    merchant_orders.each do |mo|
      unless mo.is_payment_info_valid?
        return false
      end
    end
    return true
  end

  def set_payment_codes
    has_error = false
    ActiveRecord::Base.transaction do
      merchant_orders.each do |mo|
        if !mo.set_payment_code
          has_error = true
        end
      end
      if has_error
        raise ActiveRecord::Rollback
      end
    end
    return !has_error
  end

  protected

  def add_user_info
    return if user.guest?

    a = {}

    if user.email.blank? && !user_email.blank?
      a[:email] = user_email
    end
    if user.phone.blank? && !user_phone.blank?
      a[:phone] = user_phone
    end
    if user.first_name.blank? && !user_first_name.blank?
      a[:first_name] = user_first_name
    end
    if user.last_name.blank? && !user_last_name.blank?
      a[:last_name] = user_last_name
    end
    if !a.blank?
      user.update_attributes(a)
    end

    if user_address_id.blank?
      user.addresses.create(:location_id => address.location_id, :description => address.description)
    end
  end

end

class MerchantOrder < ActiveRecord::Base

  include Modules::DateLib
  include Modules::RandomIdOwnerLib

  random_id_field :number, prefix: 'M', initial_length: 7
  random_id_field :return_code, prefix: 'R', initial_length: 6

  # Scopes
  scope :active, -> { where(status: 1) }

  # Attributes
  enum status: { active: 1, waiting_payment: 2, confirmed: 3, canceled: 4 }
  currency :shipment_price
  currency_accessor :total, :total_with_discount, :total_with_shipment
  attr_accessor :skip_email_on_status_change

  # Relations
  belongs_to :order
  belongs_to :merchant
  belongs_to :merchant_shipment
  belongs_to :merchant_payment_type
  has_one    :payment_type, through: :merchant_payment_type
  has_one    :merchant_order_return

  has_many   :merchant_order_details
  accepts_nested_attributes_for :merchant_order_details, allow_destroy: true

  has_many :merchant_order_status_changes

  # Validations
  validates_presence_of :merchant_payment_type_id
  validates_presence_of :merchant_shipment_id
  validates_presence_of :status
  validates_presence_of :cancellation_note, if: :canceled?

  validates_numericality_of :shipment_price, :greater_than_or_equal_to => 0, :on => :update

  # Callbacks
  before_create     :set_shipment_fields
  before_create     :set_status
  after_update      :add_status_change
  after_save        :on_order_status_changed, if: :status_changed?

  public

  def is_ready_for_payment?
    payment_code.present?
  end

  def is_payment_info_valid?
    is_ready_for_payment? && payment_code != Conf.payments.epay_failed_code
  end

  def on_order_status_changed
    if self.confirmed?
      if self.skip_email_on_status_change
        Rails.logger.info("Will skip the email notification for the status change")
      else
        OrderMailer.user_confirmed(self).deliver_now
      end
    elsif self.canceled?
      OrderMailer.user_canceled(self).deliver_now
    end
  end

  def total
    merchant_order_details.to_a.sum(&:total)
  end

  def total_with_discount
    merchant_order_details.to_a.sum(&:total_with_discount)
  end

  def total_with_shipment
    total_with_discount + (shipment_price || 0.0)
  end

  def aprox_delivery
    if aprox_delivery_date_from == aprox_delivery_date_to
      date_to_s(aprox_delivery_date_from)
    else
      "#{date_to_s(aprox_delivery_date_from)} - #{date_to_s(aprox_delivery_date_to)}"
    end
  end

  def return_deadline_passed?
    delivery_date = acknowledged_date || aprox_delivery_date_to
    Time.zone.today > (delivery_date + merchant.return_days.days)
  end

  def has_additional_payment?
    if merchant_payment_type.payment_type.requires_action
      return true
    end
    return false
  end

  def payment_code_human_readable
    if payment_code.blank? || payment_code == Conf.payments.no_code || payment_code == Conf.payments.epay_failed_code
      return "-"
    else
      return payment_code
    end
  end

  def set_payment_code
    if has_additional_payment?
      code = merchant_payment_type.info.generate_payment_code(number, total_with_shipment)
    else
      code = Conf.payments.no_code
    end
    if code
      return self.update_attributes(:payment_code => code)
    end
    return true
  end

  private

  def set_shipment_fields
    ret = true
    if self.shipment_price != merchant_shipment.price
      errors.add("changed_shipment_price", "Цената за доставка е променена - моля прегледайте новата цена и направете поръчката, ако тя Ви удовлетворява.")
      ret = false
    end
    if self.total_with_discount < merchant_shipment.min_order_price
      errors.add(:merchant_shipment_id, "за да изберете тази доставка, трябва поръчката Ви да надхвърля #{merchant_shipment.min_order_price_formatted}.")
      ret = false
    end
    if merchant_shipment.payment_type.present? && merchant_shipment.payment_type_id != merchant_payment_type.payment_type_id
      errors.add(:merchant_shipment_id, "за да изберете тази доставка, трябва начина на плащане да бъде  #{merchant_shipment.payment_type.name}.")
      ret = false
    end
    self.shipment_price = merchant_shipment.price
    self.aprox_delivery_date_from = merchant_shipment.date_start_from_now
    self.aprox_delivery_date_to = merchant_shipment.date_end_from_now
    ret
  end

  def set_status
    if merchant_payment_type.present? && has_additional_payment?
      self.status = "waiting_payment"
    else
      self.status = "active"
    end
    true
  end

  def add_status_change
    if status_changed?
      merchant_order_status_changes.create(status_from: MerchantOrder.statuses[status_was], status_to: MerchantOrder.statuses[status])
    end
  end

  def section
    return :orders
  end

end

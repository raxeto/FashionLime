class MerchantShipment < ActiveRecord::Base

  include Modules::DateLib

  # Attributes
  enum period_type: { business_days: 1, week_days: 2 }
  currency :price, :min_order_price

  # Relations
  belongs_to :shipment_type  
  belongs_to :payment_type  
  has_many :merchant_orders, dependent: :restrict_with_error

  # Scopes
  scope :available, -> {
    includes(:shipment_type, :payment_type).
    where(:active => 1)
  }

  # Validations
  validates :shipment_type_id, presence: true
  validates :name, presence: true
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_numericality_of :min_order_price, :greater_than_or_equal_to => 0
  validates_numericality_of :period_from, :greater_than => 0, only_integer: true
  validates_numericality_of :period_to, :greater_than => 0, only_integer: true

  validate  :period_valid

  def full_name
    n = "#{name} | #{price_formatted} | #{shipment_type.name}"

    if min_order_price >= Conf.math.PRICE_EPSILON
      n << " | Мин.поръчка: #{min_order_price_formatted}"
    end

    if payment_type.present?
      n << " | Плащане: #{payment_type.name}"
    end
    n
  end

  def period_text
    p = period_from == period_to ? "#{period_from} " : "от #{period_from} до #{period_to} "
    p << I18n.t("merchant_shipment.#{period_type}", count: period_to)
  end

  def aprox_delivery
    aprox_start = date_start_from_now
    aprox_end = date_end_from_now 
    if aprox_start == aprox_end
      "#{date_to_s_short(aprox_start)}"
    else
      "между #{date_to_s_short(aprox_start)} и #{date_to_s_short(aprox_end)}"
    end
  end

  def date_start_from_now
    date_from_now(period_from)
  end

  def date_end_from_now
    date_from_now(period_to)
  end

  private

  def period_valid
    if (!period_from.nil? && !period_to.nil? && period_from > period_to)
      errors.add(:period_from, "Срок на доставка ОТ трябва да е по-малко или равно на срок на доставка ДО.")
    end
  end

  def date_from_now(period)
    if business_days?
      period.business_days.after(Time.zone.today)
    elsif week_days?
      Time.zone.today + period.days
    end
  end

end

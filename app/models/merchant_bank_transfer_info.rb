class MerchantBankTransferInfo < ActiveRecord::Base

  include Modules::MerchantPaymentInfoLib

  # Associations
  has_one :merchant_payment_type, as: :info
  has_one :merchant, through: :merchant_payment_type

  # Validations
  validates_presence_of :company_name, :iban, :bic_code, :bank_name, :currency
  validate  :has_merchant_order, on: :update

  def text
    "Получател: #{company_name}, #{bank_name}, IBAN: #{iban}, BIC: #{bic_code}, Валута: #{currency}."
  end

  def generate_payment_code order_id, order_price
    order_id.to_s
  end

end

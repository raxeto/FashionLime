class MerchantPaymentType < ActiveRecord::Base

  # Relations
  belongs_to :merchant
  belongs_to :payment_type
  belongs_to :info, polymorphic: true

  # Validations
  validates_presence_of :payment_type
  validates_presence_of :merchant
  validate  :only_available_per_payment_type

  # Callbacks
  after_initialize :create_info, :if => :new_record?

  # Scopes
  scope :available, -> {
    includes(:payment_type).
    where(:active => 1)
  }

  def payment_type_name
    payment_type.name
  end

  def info_text
    info.try(:text) || "-"
  end

  # Helps to save both the info and merchant_payment_type
  # Because if info is not valid the merchant_payment_type is still saved
  def save_payment
    success = true
    if info.present? 
      success = info.save
    end
    if success
      success = save
    end
    success
  end

  private

  def only_available_per_payment_type
    if active == 1 && payment_type.present? && merchant.present? && MerchantPaymentType.where("id != ? and merchant_id = ? and payment_type_id = ? and active = 1", id || 0, merchant_id, payment_type_id).size > 0
      errors.add(:available, "Може да имате само един активен запис в даден момент за всеки начин на плащане. Ако искате да въведете нова информация за този начин на плащане, деактивирайте първо стария запис чрез полето Активен Да/Не.")
    end
  end

  def create_info
    if payment_type.present? && payment_type.info_class_name.present?
      self.info = payment_type.info_class_name.constantize.new
      # Only BGN for now
      if self.info_type == "MerchantBankTransferInfo"
        self.info.currency = "BGN"
      end
    end
  end

end

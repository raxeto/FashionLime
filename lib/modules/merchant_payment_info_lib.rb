module Modules
  module MerchantPaymentInfoLib

    def has_merchant_order
      if changed? && MerchantOrder.where( :merchant_payment_type_id => merchant_payment_type.id).size > 0
        errors.add(:order_exists, "Вече има направени поръчки с това плащане. Ако искате да промените данните за бъдещи поръчки деактивирайте това плащане чрез полето Активен Да/Не и въведете ново активно със същия начин на плащане.")
      end
    end

  end
end

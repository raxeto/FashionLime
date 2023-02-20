class AddIndexByPaymentTypeIdOnMerchantPaymentTypes < ActiveRecord::Migration
  def change
     add_index :merchant_payment_types, [:payment_type_id]
  end
end

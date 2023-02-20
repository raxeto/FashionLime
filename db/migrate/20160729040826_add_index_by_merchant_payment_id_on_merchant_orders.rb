class AddIndexByMerchantPaymentIdOnMerchantOrders < ActiveRecord::Migration
  def change
     add_index :merchant_orders, [:merchant_payment_type_id]
  end
end

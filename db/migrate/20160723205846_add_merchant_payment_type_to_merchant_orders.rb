class AddMerchantPaymentTypeToMerchantOrders < ActiveRecord::Migration
  def change
    change_table(:merchant_orders) do |t|
      t.references :merchant_payment_type, index: false, null: false
      t.string :payment_code
    end

    remove_column :merchant_orders, :payment_type_id
  end
end
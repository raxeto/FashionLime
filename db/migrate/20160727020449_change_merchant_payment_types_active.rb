class ChangeMerchantPaymentTypesActive < ActiveRecord::Migration
  def change
    remove_column :merchant_payment_types, :active
    change_table(:merchant_payment_types) do |t|
      t.integer    :active, null: false, default: 1, after: :info_type
    end
  end
end

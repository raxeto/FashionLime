class AddPaymentInfoToMerchantPaymentTypes < ActiveRecord::Migration
  def change
    change_table(:merchant_payment_types) do |t|
      t.references :info, polymorphic: true, index: false
      t.boolean    :active, null: false
    end

    add_index :merchant_payment_types, [:info_id, :info_type]
  end
end

class CreateMerchantPaymentTypes < ActiveRecord::Migration
  def change
    create_table :merchant_payment_types do |t|
      t.references :merchant, null: false, index: true
      t.references :payment_type, null: false
      t.timestamps null: false
    end
  end
end

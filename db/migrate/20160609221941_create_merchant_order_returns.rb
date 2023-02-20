class CreateMerchantOrderReturns < ActiveRecord::Migration
  def change
    create_table :merchant_order_returns do |t|
      t.references :merchant_order, null: false, index: true
      t.text       :note_to_merchant
      t.string     :user_first_name, limit: 1024
      t.string     :user_last_name, limit: 1024
      t.string     :user_email, null: true
      t.string     :user_phone, null: true
      t.integer    :status, null: false, default: 1
      t.timestamps null: false
    end
  end
end

class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :user, null: false, index: true
      t.integer    :only_business_days, default: 1
      t.text       :note_to_merchants
      t.string     :user_first_name, limit: 1024
      t.string     :user_last_name, limit: 1024
      t.string     :user_email, null: true
      t.string     :user_phone, null: true
      t.integer    :status, null: false, default: 1
      t.timestamps null: false
    end
  end
end

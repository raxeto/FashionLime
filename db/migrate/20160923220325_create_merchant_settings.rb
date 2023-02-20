class CreateMerchantSettings < ActiveRecord::Migration
  def change
    create_table :merchant_settings do |t|
      t.references :merchant, null: false
      t.string     :key, null: false, limit: 128
      t.string     :value, null: false, limit: 512
      t.timestamps null: false
    end
     add_index :merchant_settings, [:merchant_id, :key], :unique => true

  end
end

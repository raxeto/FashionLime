class CreateMerchantProductApiMappings < ActiveRecord::Migration
  def change
    create_table :merchant_product_api_mappings do |t|
      t.references :merchant, index: true
      t.string     :from_key, null: false
      t.string     :to_type, null: false
      t.timestamps null: false
    end

    add_index :merchant_product_api_mappings, [:merchant_id, :to_type], unique: true
  end
end

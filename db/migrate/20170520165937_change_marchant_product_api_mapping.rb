class ChangeMarchantProductApiMapping < ActiveRecord::Migration
  def change
    change_table(:merchant_product_api_mappings) do |t|
      t.string     :input_value, null: false, after: :from_key, limit: 220
      t.references :object, polymorphic: true, null: false, after: :from_key
    end

    remove_column :merchant_product_api_mappings, :to_type
    remove_column :merchant_product_api_mappings, :from_key
    remove_index :merchant_product_api_mappings, :name => 'index_merchant_product_api_mappings_on_merchant_id_and_to_type'
    remove_index :merchant_product_api_mappings, :name => 'index_merchant_product_api_mappings_on_merchant_id'
    add_index :merchant_product_api_mappings, [:merchant_id, :object_type, :input_value], unique: true, name: "merchant_product_api_mappings_input_value_to_object"
  end
end

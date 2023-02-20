class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
      t.string     :name, null: false,  limit: 1024
      t.string     :key, null: false,  limit: 128
      t.references :parent, null: true, index: true
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
    add_index :product_categories, :key, :unique => true
  end
end

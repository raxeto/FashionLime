class CreateOutfitCategories < ActiveRecord::Migration
  def change
    create_table :outfit_categories do |t|
      t.string     :name, null: false,  limit: 255
      t.text       :description, null: true
      t.string     :key, null: false,  limit: 128
      t.string     :url_path, null: false, limit: 255
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
    add_index :outfit_categories, :key, :unique => true
    add_index :outfit_categories, :url_path, :unique => true
  end
end

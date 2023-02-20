class CreateSizeCategoryProductCategories < ActiveRecord::Migration
  def change
    create_table :size_category_product_categories do |t|
      t.references :size_category, null: false, index: true
      t.references :product_category, null: false, index: true
      t.timestamps null: false
    end
  end
end

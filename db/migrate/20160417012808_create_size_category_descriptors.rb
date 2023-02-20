class CreateSizeCategoryDescriptors < ActiveRecord::Migration
  def change
    create_table :size_category_descriptors do |t|
      t.references :size_category, null: false, index: true
      t.references :size_descriptor, null: false
      t.timestamps null: false
    end
  end
end

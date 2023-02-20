class CreateSizeCategories < ActiveRecord::Migration
  def change
    create_table :size_categories do |t|
      t.string     :name, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end

    change_table(:sizes) do |t|
      t.references :size_category, null: true, index: true
    end
  end
end

class AddUrlPathDescriptionToProductCategory < ActiveRecord::Migration
  def change
    change_table(:product_categories) do |t|
      t.text       :description, null: true, after: :name
      t.string     :url_path, null: false, limit: 255, after: :parent_id
    end
    add_index :product_categories, [:url_path]
  end
end

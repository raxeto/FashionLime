class AddStatusToProductCategories < ActiveRecord::Migration
  def change
    change_table(:product_categories) do |t|
      t.integer    :status, null: false, default: 1, after: :parent_id
    end
  end
end

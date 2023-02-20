class AddCollectionToProduct < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.references :product_collection, null: true, index: true
    end
  end
end

class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :merchant_order_details, [:article_id]
    add_index :merchant_order_quantities, [:article_quantity_id]
    add_index :addresses, [:owner_id]
    add_index :merchant_orders, [:merchant_id, :status]
    add_index :outfits, [:profile_id]
  end
end

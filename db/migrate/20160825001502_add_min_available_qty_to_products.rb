class AddMinAvailableQtyToProducts < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.decimal    :min_available_qty, :precision => 8, :scale => 3, null: true, after: :product_collection_id
    end
  end
end

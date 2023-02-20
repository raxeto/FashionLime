class CreateProductSizes < ActiveRecord::Migration
  def change
    create_table :product_sizes do |t|
      t.references :product, index: true, null: false
      t.references :size, null: false
      t.timestamps null: false
    end
  end
end

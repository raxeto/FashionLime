class CreateProductOccasions < ActiveRecord::Migration
  def change
    create_table :product_occasions do |t|
      t.references :product, null: false, index: true
      t.references :occasion, null: false, index: true
      t.timestamps null: false
    end
  end
end

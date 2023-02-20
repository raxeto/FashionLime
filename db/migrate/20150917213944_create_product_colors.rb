class CreateProductColors < ActiveRecord::Migration
  def change
    create_table :product_colors do |t|
      t.references :product, index: true, null: false
      t.references :color, null: false
      t.timestamps null: false
    end
  end
end

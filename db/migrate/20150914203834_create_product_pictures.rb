class CreateProductPictures < ActiveRecord::Migration
  def change
    create_table :product_pictures do |t|
      t.references :product, index: true
      t.attachment :picture
      t.integer    :outfit_compatible, default: 0, null: false
      t.integer    :order_index, null: false
      t.timestamps null: false
    end
  end
end

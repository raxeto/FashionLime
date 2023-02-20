class CreateOutfitProductPictures < ActiveRecord::Migration
  def change
    create_table :outfit_product_pictures do |t|
      t.references :outfit, index: true, null: false
      t.references :product_picture, index: true, null: false
      t.integer    :instances_count, null: false
      t.timestamps null: false
    end
  end
end

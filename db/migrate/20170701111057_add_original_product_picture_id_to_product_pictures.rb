class AddOriginalProductPictureIdToProductPictures < ActiveRecord::Migration
  def change
    change_table(:product_pictures) do |t|
      t.integer  :original_product_picture_id
    end
  end
end

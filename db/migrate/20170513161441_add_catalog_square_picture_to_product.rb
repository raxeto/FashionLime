class AddCatalogSquarePictureToProduct < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.attachment :catalog_square_picture
    end
  end
end

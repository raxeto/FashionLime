class AddCatalogPictureToProduct < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.attachment :catalog_picture
    end
  end
end

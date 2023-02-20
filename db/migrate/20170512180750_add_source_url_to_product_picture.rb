class AddSourceUrlToProductPicture < ActiveRecord::Migration
  def change
    add_column :product_pictures, :source_url, :string
    add_index :product_pictures, :source_url
  end
end
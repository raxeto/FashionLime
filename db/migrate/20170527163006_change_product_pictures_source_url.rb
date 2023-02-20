class ChangeProductPicturesSourceUrl < ActiveRecord::Migration
  def change
    remove_index :product_pictures, :name => 'index_product_pictures_on_source_url'
    change_column :product_pictures, :source_url, :string, :limit => 2048
  end
end

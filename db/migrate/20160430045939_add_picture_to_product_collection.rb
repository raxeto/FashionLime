class AddPictureToProductCollection < ActiveRecord::Migration
   def change
    change_table(:product_collections) do |t|
      t.attachment :picture, :after => :year
    end
  end
end

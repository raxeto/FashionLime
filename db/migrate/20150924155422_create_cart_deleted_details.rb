class CreateCartDeletedDetails < ActiveRecord::Migration
  def change
    create_table :cart_deleted_details do |t|
      t.references :article, null: false, index: true
      t.references :user, null: true
      t.decimal    :price,  :precision => 8, :scale => 2
      t.decimal    :perc_discount,  :precision => 8, :scale => 2
      t.decimal    :price_with_discount,  :precision => 8, :scale => 2
      t.decimal    :qty,  :precision => 8, :scale => 3
      t.datetime   :added_at, null: false
      t.timestamps null: false
    end
  end
end

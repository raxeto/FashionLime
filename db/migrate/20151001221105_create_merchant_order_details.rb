class CreateMerchantOrderDetails < ActiveRecord::Migration
  def change
    create_table :merchant_order_details do |t|
      t.references :merchant_order, null: false, index: true
      t.references :article, null: false

      t.decimal    :price,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :perc_discount,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :price_with_discount,  :precision => 8, :scale => 2, default: 0.0
     
      t.decimal    :qty,  :precision => 8, :scale => 3, default: 0.0
     
      t.decimal    :total,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :total_with_discount, :precision => 8, :scale => 2, default: 0.0

      t.timestamps null: false
    end
  end
end

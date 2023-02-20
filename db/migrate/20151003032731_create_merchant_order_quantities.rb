class CreateMerchantOrderQuantities < ActiveRecord::Migration
  def change
    create_table :merchant_order_quantities do |t|
      t.references :merchant_order_detail, null: false, index: true
      t.references :article_quantity, null: false

      t.decimal    :qty,  :precision => 8, :scale => 3, default: 0.0
      
      t.timestamps null: false
    end
  end
end

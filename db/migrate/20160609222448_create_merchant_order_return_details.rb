class CreateMerchantOrderReturnDetails < ActiveRecord::Migration
  def change
    create_table :merchant_order_return_details do |t|
      t.references :merchant_order_return, null: false, index: true
      t.references :merchant_order_detail, null: false, index: true
      t.decimal    :return_qty,  :precision => 8, :scale => 3, default: 0.0
      t.timestamps null: false
    end
  end
end

class CreateMerchantOrders < ActiveRecord::Migration
  def change
    create_table :merchant_orders do |t|
      t.references :order, null: false, index: true
      t.references :merchant, null: false, index: true

      t.references :payment_type, null: false
      t.references :merchant_shipment, null: false

      t.decimal    :shipment_price,  :precision => 8, :scale => 2, default: 0.0

      t.datetime   :aprox_delivery_date_from
      t.datetime   :aprox_delivery_date_to
      t.datetime   :acknowledged_date

      t.text       :note_to_user
      t.integer    :status, null: false, default: 1

      t.timestamps null: false
    end
  end
end

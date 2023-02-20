class CreateMerchantShipments < ActiveRecord::Migration
  def change
    create_table :merchant_shipments do |t|
      t.references :merchant, null: false, index: true

      t.references :shipment_type, null: false
      t.references :payment_type, null: true

      t.string     :name, limit: 512, null: false, default: ""
      t.string     :description, limit: 2048, null: true

      t.decimal    :price,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :min_order_price,  :precision => 8, :scale => 2, default: 0.0

      t.integer    :period_from, null: false, default: 0
      t.integer    :period_to, null: false, default: 0
      t.integer    :period_type, null: false, default: 1

      t.integer    :active, null: false, default: 1

      t.timestamps null: false
    end
  end
end

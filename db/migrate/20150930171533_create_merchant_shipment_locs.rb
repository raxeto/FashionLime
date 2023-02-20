class CreateMerchantShipmentLocs < ActiveRecord::Migration
  def change
    create_table :merchant_shipment_locs do |t|
      t.references :merchant_shipment, null: false, index: true
      t.references :location, null: false
      t.timestamps null: false
    end
  end
end

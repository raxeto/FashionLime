class CreateShipmentTypes < ActiveRecord::Migration
  def change
    create_table :shipment_types do |t|
      t.string     :name, null: false,  limit: 512
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

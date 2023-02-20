class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string     :name, null: false,  limit: 1024
      t.references :parent, null: true, index: true
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

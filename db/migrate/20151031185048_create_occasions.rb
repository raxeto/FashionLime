class CreateOccasions < ActiveRecord::Migration
  def change
    create_table :occasions do |t|
      t.string     :name, null: false,  limit: 1024
      t.string     :key, null: false,  limit: 128
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end


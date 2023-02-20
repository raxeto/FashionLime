class AddLocationTypeToLocations < ActiveRecord::Migration
  def change
    change_table(:locations) do |t|
      t.references :location_type, null: false, index: true, :after => :order_index
    end
  end
end

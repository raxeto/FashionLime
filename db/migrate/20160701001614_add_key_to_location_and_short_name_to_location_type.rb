class AddKeyToLocationAndShortNameToLocationType < ActiveRecord::Migration
  def change
    change_table(:locations) do |t|
      t.string     :key, limit: 10, after: :location_type_id
    end
    change_table(:location_types) do |t|
      t.string     :short_name, limit: 30, after: :key
    end
     add_index :locations, :key, :unique => true
  end
end

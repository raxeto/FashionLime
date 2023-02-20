class CreateLocationTypes < ActiveRecord::Migration
  def change
    create_table :location_types do |t|
      t.string     :name, null: false
      t.string     :key, null: false
      t.timestamps null: false
    end
  end
end

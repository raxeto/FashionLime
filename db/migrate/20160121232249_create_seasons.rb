class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string     :name, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

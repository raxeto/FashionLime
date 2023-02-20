class CreateSizeCharts < ActiveRecord::Migration
  def change
    create_table :size_charts do |t|
      t.string     :name, null: false, default: "", limit: 1024
      t.references :merchant, null: false, index: true
      t.references :size_category, null: false, index: false
      t.text       :note, null: true
      t.timestamps null: false
    end

    add_index :size_charts, [:merchant_id, :size_category_id], :unique => false

  end
end

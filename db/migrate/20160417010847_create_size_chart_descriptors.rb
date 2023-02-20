class CreateSizeChartDescriptors < ActiveRecord::Migration
  def change
    create_table :size_chart_descriptors do |t|
      t.references :size_chart, null: false, index: true
      t.references :size, null: false
      t.references :size_descriptor, null: false
      t.decimal    :value_from,  :precision => 8, :scale => 2, default: 0.0, null: false
      t.decimal    :value_to,    :precision => 8, :scale => 2, default: 0.0, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

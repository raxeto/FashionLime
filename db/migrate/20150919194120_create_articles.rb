class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.references :product, null: false, index: true
      t.references :size, null: true, index: true
      t.references :color, null: true, index: true
      t.string     :name, null: true, limit: 2048
      t.decimal    :price,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :perc_discount,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :price_with_discount,  :precision => 8, :scale => 2, default: 0.0
      t.decimal    :available_qty,  :precision => 8, :scale => 3, default: 0.0
      t.timestamps null: false
    end
  end
end

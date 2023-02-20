class CreateOutfitDecorations < ActiveRecord::Migration
  def change
    create_table :outfit_decorations do |t|
      t.integer :category, null: false, default: 1, index: true
      t.integer :order_index, null: false, default: 1
      t.attachment :picture
      t.timestamps null: false
    end
  end
end

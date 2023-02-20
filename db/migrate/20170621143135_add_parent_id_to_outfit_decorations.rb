class AddParentIdToOutfitDecorations < ActiveRecord::Migration
  def change
    change_table(:outfit_decorations) do |t|
      t.references :parent, null: true, index: true
    end
  end
end

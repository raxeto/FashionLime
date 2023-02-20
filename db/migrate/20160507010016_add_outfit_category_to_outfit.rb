class AddOutfitCategoryToOutfit < ActiveRecord::Migration
  def change
    change_table(:outfits) do |t|
      t.references :outfit_category, null: false, index: true, :after => :rating
    end
  end
end

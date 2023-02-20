class AddImageFilterToOutfit < ActiveRecord::Migration
  def change
    change_table(:outfits) do |t|
      t.integer     :image_filter, null: true, after: :outfit_category_id
    end
  end
end

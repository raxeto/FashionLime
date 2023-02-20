class RemoveMetaTitleAndDescriptionFromOutfitCategoryAndOccasion < ActiveRecord::Migration
  def change
    remove_column :outfit_categories, :meta_title
    remove_column :outfit_categories, :meta_description
    remove_column :occasions,         :meta_title
    remove_column :occasions,         :meta_description
  end
end

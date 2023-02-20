class AddOgImageToProductCategoryAndSearchPage < ActiveRecord::Migration
  def change
    change_table(:product_categories) do |t|
      t.attachment :og_image, after: :meta_description
    end
    change_table(:search_pages) do |t|
      t.attachment :og_image, after: :meta_description
    end
  end
end

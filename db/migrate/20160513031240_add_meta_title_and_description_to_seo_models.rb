class AddMetaTitleAndDescriptionToSeoModels < ActiveRecord::Migration
  def change
    change_table(:product_categories) do |t|
      t.string     :meta_title, null: true, limit: 255, after: :url_path
      t.string     :meta_description, null: true, limit: 512, after: :meta_title
    end
    change_table(:occasions) do |t|
      t.string     :meta_title, null: true, limit: 255, after: :url_path
      t.string     :meta_description, null: true, limit: 512, after: :meta_title
    end
    change_table(:outfit_categories) do |t|
      t.string     :meta_title, null: true, limit: 255, after: :url_path
      t.string     :meta_description, null: true, limit: 512, after: :meta_title
    end
    change_table(:search_pages) do |t|
      t.string     :meta_title, null: true, limit: 255, after: :url_path
      t.string     :meta_description, null: true, limit: 512, after: :meta_title
    end
  end
end

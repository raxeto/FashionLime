class CreateSearchPages < ActiveRecord::Migration
  def change
    create_table :search_pages do |t|
      t.string     :title, null: false, limit: 1024
      t.text       :description, null: true
      t.string     :url_path, null: false, limit: 250
      t.integer    :category, null: false
      t.timestamps null: false
    end
    add_index :search_pages, [:url_path, :category], :unique => true
  end
end

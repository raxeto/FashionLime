class CreateHomePageLinks < ActiveRecord::Migration
  def change
    create_table :home_page_links do |t|
      t.string :title, limit: 2048
      t.string :subtitle, limit: 4096
      t.string :url_path, null: false, limit: 1024
      t.integer :position, null: false, default: 1
      t.attachment :picture
      t.timestamps null: false
    end
  end
end

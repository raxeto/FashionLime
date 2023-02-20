class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string     :title, null: false, limit: 1024
      t.string     :subtitle, null: true, limit: 2048
      t.text       :text, null: true
      t.string     :source_title, null: true, limit: 1024
      t.string     :source_link, null: true, limit: 2048
      t.attachment :main_picture
      t.integer    :main_picture_width, null: true
      t.integer    :main_picture_height, null: true
      t.references :user, null: false
      t.string     :url_path, null: false, limit: 255
      t.timestamps null: false
    end
    add_index :blog_posts, [:url_path], :unique => true
  end
end

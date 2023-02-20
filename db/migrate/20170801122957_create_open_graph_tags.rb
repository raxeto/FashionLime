class CreateOpenGraphTags < ActiveRecord::Migration
  def change
    create_table :open_graph_tags do |t|
      t.string     :page_link, null: false, limit: 1500, index: true
      t.string     :title, null: true, limit: 512
      t.string     :description, null: true, limit: 1024
      t.attachment :picture
      t.integer    :picture_width, null: true
      t.integer    :picture_height, null: true
      t.timestamps null: false
    end
  end
end

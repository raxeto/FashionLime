class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string     :title, null: false, limit: 1024
      t.text       :description, null: true
      t.string     :url_path, null: false, limit: 250
      t.attachment :picture
      t.timestamps null: false
    end
  end
end

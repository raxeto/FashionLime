class CreateCampaignGroups < ActiveRecord::Migration
  def change
    create_table :campaign_groups do |t|
      t.references :campaign, null: false, index: true
      t.string :label, null: false, limit: 2048
      t.string :see_more_url, null: true, limit: 1024
      t.integer :order_index, null: false, default: 0
      t.timestamps null: false
    end
  end
end

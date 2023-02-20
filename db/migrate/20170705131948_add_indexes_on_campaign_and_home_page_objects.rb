class AddIndexesOnCampaignAndHomePageObjects < ActiveRecord::Migration
  def change
    add_index :campaign_objects, [:object_id, :object_type]
    add_index :home_page_objects, [:object_id, :object_type]
  end
end

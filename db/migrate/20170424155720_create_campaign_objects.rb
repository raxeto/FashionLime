class CreateCampaignObjects < ActiveRecord::Migration
  def change
    create_table :campaign_objects do |t|
      t.references :campaign, null: false, index: true
      t.references :object, polymorphic: true, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

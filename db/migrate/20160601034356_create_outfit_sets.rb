class CreateOutfitSets < ActiveRecord::Migration
  def change
    create_table :outfit_sets do |t|
      t.references :outfit_category, null: true
      t.references :occasion, null: true
      t.string     :meta_title, null: true, limit: 255
      t.string     :meta_description, null: true, limit: 512
      t.attachment :og_image
      t.timestamps null: false
    end
    add_index :outfit_sets, [:outfit_category_id, :occasion_id], :unique => true
  end
end

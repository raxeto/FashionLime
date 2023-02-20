class CreateOutfits < ActiveRecord::Migration
  def change
    create_table :outfits do |t|
      t.string     :name, limit: 1024
      t.references :user, null: false
      t.float      :rating, null: false, default: 0.0
      t.text       :serialized_json
      t.attachment :picture
      t.timestamps null: false
    end
  end
end

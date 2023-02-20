class CreateOutfitOccasions < ActiveRecord::Migration
  def change
    create_table :outfit_occasions do |t|
      t.references :outfit, null: false, index: true
      t.references :occasion, null: false, index: true
      t.timestamps null: false
    end
  end
end

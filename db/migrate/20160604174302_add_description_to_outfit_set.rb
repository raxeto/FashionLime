class AddDescriptionToOutfitSet < ActiveRecord::Migration
  def change
    change_table(:outfit_sets) do |t|
      t.text       :description, null: true, after: :occasion_id
    end
  end
end

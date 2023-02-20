class AddProfileToOutfit < ActiveRecord::Migration
  def change
    change_table(:outfits) do |t|
      t.references :profile, null: false, :after => :user_id
    end
  end
end

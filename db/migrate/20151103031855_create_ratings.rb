class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :owner, polymorphic: true, index: true, null: false
      t.references :profile, null: false
      t.references :user, null: false
      t.float      :rating, null: false
      t.timestamps null: false
    end

    add_index :ratings, [:profile_id, :owner_type, :owner_id], :unique => true
  end
end

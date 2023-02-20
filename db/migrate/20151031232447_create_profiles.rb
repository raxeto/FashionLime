class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :owner, polymorphic: true
      t.timestamps null: false
    end
    
    add_index :profiles, [:owner_id, :owner_type], unique: true

    change_table(:users) do |t|
      t.references :profile
    end
  end
end

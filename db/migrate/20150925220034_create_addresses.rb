class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :owner, polymorphic: true
      t.references :location, null: true
      t.text       :description
      t.timestamps null: false
    end
  end
end

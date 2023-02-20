class CreateRegisteredUserGuests < ActiveRecord::Migration
  def change
    create_table :registered_user_guests do |t|
      t.references :user, null: false
      t.references :guest, null: false, index: true
      t.timestamps null: false
    end
  end
end

class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, index: true
      t.string     :role, null: false

      t.timestamps null: false
    end
  end
end

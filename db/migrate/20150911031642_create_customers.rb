class CreateCustomers < ActiveRecord::Migration
  def change
    create_table  :customers do |t|
      t.references :user
      t.string     :first_name, limit: 1024, default: ''
      t.string     :last_name, limit: 1024, default: ''
      t.attachment :avatar
      t.float      :rating
      t.string     :gender, limit: 1
      t.datetime   :birth_date
      t.timestamps null: false
    end

    add_index :customers, :user_id, :unique => true
  end
end

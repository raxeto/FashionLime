class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string     :name, null: false
      t.string     :code, null: false, limit: 10
      t.timestamps null: false
    end
  end
end

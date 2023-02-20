class CreateCustomTasks < ActiveRecord::Migration
  def change
    create_table :custom_tasks do |t|
      t.string     :code, null: false, limit: 128
      t.integer    :in_progress, null: false, default: 0
      t.timestamps null: false
    end
    add_index :custom_tasks, :code, :unique => true
  end
end

class AddStatusToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.integer    :status, null: false, default: 1
    end
  end
end

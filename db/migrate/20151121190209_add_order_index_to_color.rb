class AddOrderIndexToColor < ActiveRecord::Migration
  def self.up
   change_table(:colors) do |t|
      t.integer    :order_index, null: false, default: 1
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

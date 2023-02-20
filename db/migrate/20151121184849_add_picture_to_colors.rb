class AddPictureToColors < ActiveRecord::Migration
  def self.up
   change_table(:colors) do |t|
      t.attachment :picture
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

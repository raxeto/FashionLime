class AddColorToProductPicture < ActiveRecord::Migration
  def self.up
   change_table(:product_pictures) do |t|
      t.references :color
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

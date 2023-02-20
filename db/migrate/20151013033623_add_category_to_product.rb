class AddCategoryToProduct < ActiveRecord::Migration
  def self.up
   change_table(:products) do |t|
      t.references :product_category, null: false, index: true, :after => :status
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

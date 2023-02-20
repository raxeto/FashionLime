class AddEmailPromotionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_promotions, :boolean, null: false, default: true
    add_index :users, :email_promotions
  end
end

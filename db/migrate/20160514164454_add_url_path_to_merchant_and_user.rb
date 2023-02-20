class AddUrlPathToMerchantAndUser < ActiveRecord::Migration
   def change
    change_table(:merchants) do |t|
      t.string     :url_path, null: false, limit: 255, after: :status
    end
    change_table(:users) do |t|
      t.string     :url_path, null: false, limit: 255, after: :profile_id
    end

    Merchant.all.each { |m| m.update_attributes(:url_path => m.name.parameterize)}
    User.all.each     { |u| u.update_attributes(:url_path => u.username.parameterize)}

    add_index :merchants, [:url_path], :unique => true
    add_index :users, [:url_path], :unique => true
  end
end

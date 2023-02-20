class CreateMerchantUsers < ActiveRecord::Migration
  def change
    create_table :merchant_users do |t|
      t.references :merchant, index: true
      t.references :user, index: true
      t.timestamps null: false
    end

  end
end

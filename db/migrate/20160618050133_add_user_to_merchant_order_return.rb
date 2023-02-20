class AddUserToMerchantOrderReturn < ActiveRecord::Migration
  def change
    change_table(:merchant_order_returns) do |t|
      t.references :user, null: false, index: true, after: :merchant_order_id
    end
  end
end

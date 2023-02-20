class AddReturnCodeToMerchantOrder < ActiveRecord::Migration
  def change
    change_table(:merchant_orders) do |t|
      t.string     :return_code, null: true, limit: 255, after: :status
      t.integer    :return_attempts, null: false, default: 0, after: :return_code
    end
    add_index :merchant_orders, [:return_code], :unique => true
  end
end

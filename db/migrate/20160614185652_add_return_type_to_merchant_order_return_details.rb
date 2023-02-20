class AddReturnTypeToMerchantOrderReturnDetails < ActiveRecord::Migration
  def change
    change_table(:merchant_order_return_details) do |t|
      t.integer    :return_type, null: false, default: 1, after: :return_qty
    end
  end
end

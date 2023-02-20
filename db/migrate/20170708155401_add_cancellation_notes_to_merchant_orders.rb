class AddCancellationNotesToMerchantOrders < ActiveRecord::Migration
  def change
    add_column :merchant_orders, :cancellation_note, :text
  end
end

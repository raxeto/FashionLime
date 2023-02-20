class CreateMerchantOrderStatusChanges < ActiveRecord::Migration
  def change
    create_table :merchant_order_status_changes do |t|
      t.references :merchant_order, null: false, index: true
      t.integer    :status_from, null: false
      t.integer    :status_to, null: false
      t.timestamps null: false
    end
  end
end

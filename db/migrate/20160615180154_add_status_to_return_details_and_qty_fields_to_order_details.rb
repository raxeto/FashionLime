class AddStatusToReturnDetailsAndQtyFieldsToOrderDetails < ActiveRecord::Migration
  def change
    change_table(:merchant_order_return_details) do |t|
      t.integer    :status, null: false, default: 1, after: :return_type
    end
    change_table(:merchant_order_details) do |t|
      t.decimal    :qty_to_return, :precision => 8, :scale => 3, null: false, default: 0.0, after: :qty
      t.decimal    :qty_returned,  :precision => 8, :scale => 3, null: false, default: 0.0, after: :qty_to_return
    end
  end
end

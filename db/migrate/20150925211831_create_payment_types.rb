class CreatePaymentTypes < ActiveRecord::Migration
  def change
    create_table :payment_types do |t|
      t.string     :name, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end

class AddNumberToMerchantOrders < ActiveRecord::Migration
  def up
    change_table(:merchant_orders) do |t|
      t.string     :number, null: true
    end
    add_index :merchant_orders, [:number], unique: true

    ActiveRecord::Base.transaction do
      MerchantOrder.all.each do |mo|
        if mo.number.blank?
          mo.set_random_ids
          mo.save
        end
      end
    end
  end

  def down
    remove_index  :merchant_orders, [:number]
    remove_column :merchant_orders, :number
  end
end

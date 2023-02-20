class AddInfoClassNameToPaymentTypes < ActiveRecord::Migration
  def change
    change_table(:payment_types) do |t|
      t.string     :info_class_name, null: true, limit: 255
    end
  end
end

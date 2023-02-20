class AddRequiresActionToPaymentTypes < ActiveRecord::Migration
  def change
    change_table(:payment_types) do |t|
      t.boolean    :requires_action, default: false
    end
  end
end

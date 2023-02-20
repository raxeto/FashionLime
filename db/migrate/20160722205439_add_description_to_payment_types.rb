class AddDescriptionToPaymentTypes < ActiveRecord::Migration
  def change
    change_table(:payment_types) do |t|
      t.text       :description, null: true, after: :name
    end
  end
end

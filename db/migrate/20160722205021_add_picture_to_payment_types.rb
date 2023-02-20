class AddPictureToPaymentTypes < ActiveRecord::Migration
  def change
    change_table(:payment_types) do |t|
      t.attachment :picture, after: :name
    end
  end
end

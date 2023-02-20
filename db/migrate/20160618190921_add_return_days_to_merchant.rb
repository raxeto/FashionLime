class AddReturnDaysToMerchant < ActiveRecord::Migration
  def change
    change_table(:merchants) do |t|
      t.integer    :return_days, null: false, default: 14, after: :return_policy
    end
  end
end

class CreateMerchantEpayInfos < ActiveRecord::Migration
  def change
    create_table :merchant_epay_infos do |t|
      t.string :min_code, limit: 64

      t.timestamps null: false
    end
  end
end

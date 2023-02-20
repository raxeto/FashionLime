class AddSecretToMerchantEpayInfo < ActiveRecord::Migration
  def change
    change_table :merchant_epay_infos do |t|
      t.string :secret, limit: 128
    end
  end
end

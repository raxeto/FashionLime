class AddSectedEncryptedToMerchantEpayInfos < ActiveRecord::Migration
  def change
    change_table(:merchant_epay_infos) do |t|
      t.string :encrypted_secret, null: false, limit: 1024, after: :min_code
      t.string :encrypted_secret_iv, null: false, limit: 1024, after: :encrypted_secret
    end
    remove_column :merchant_epay_infos, :secret
  end
end

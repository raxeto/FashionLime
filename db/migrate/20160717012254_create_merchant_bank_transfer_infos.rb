class CreateMerchantBankTransferInfos < ActiveRecord::Migration
  def change
    create_table :merchant_bank_transfer_infos do |t|
      t.string :company_name, limit: 256
      t.string :iban,         limit: 64
      t.string :bic_code,     limit: 16
      t.string :currency,     limit: 8

      t.string :bank_name,    limit: 128
      t.string :bank_address, limit: 128

      t.timestamps null: false
    end
  end
end

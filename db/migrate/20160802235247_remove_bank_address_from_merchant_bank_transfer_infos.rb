class RemoveBankAddressFromMerchantBankTransferInfos < ActiveRecord::Migration
  def change
    remove_column :merchant_bank_transfer_infos, :bank_address
  end
end

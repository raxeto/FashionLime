class MerchantProductsSyncTask < ActiveRecord::Base

  def self.is_in_progress_for_merchant(merchant_id)
    return MerchantProductsSyncTask.where(:merchant_id => merchant_id).select(:in_progress).first.try(:in_progress) == 1
  end

end

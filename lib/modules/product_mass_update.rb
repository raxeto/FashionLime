module Modules
  class ProductMassUpdate

    def self.is_in_progress(product)
      return CustomTask.is_in_progress("UPLOAD_OUTFIT_PICTURES") ||
             MerchantProductsSyncTask.is_in_progress_for_merchant(product.merchant_id)
    end
  end
end
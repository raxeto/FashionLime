class MerchantSetting < ActiveRecord::Base
  belongs_to :merchant

  after_commit :update_es_indexes, on: [:update, :create, :destroy]

  def update_es_indexes
    merchant.products.each do |product|
      # Update all products for this merchant
      Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
      Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id)
    end
  end
end

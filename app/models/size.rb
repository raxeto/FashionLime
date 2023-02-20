class Size < ActiveRecord::Base

    # Relations
    belongs_to  :size_category

    has_many :product_sizes
    has_many :products, :through => :product_sizes

    def update_es_index
      self.reload
      products.each do |product|
        # Update all products with this occasion
        Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
        Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id)
      end
    end

end

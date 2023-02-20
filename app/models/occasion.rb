class Occasion < ActiveRecord::Base

  has_many :outfit_occasions
  has_many :product_occasions

  has_many :outfits, :through => :outfit_occasions
  has_many :products, :through => :product_occasions

  after_commit :update_es_index, on: [:update, :destroy]

  def update_es_index
    self.reload
    outfits.each do |outfit|
      # Update all outfits with this occasion
      Modules::DelayedJobs::EsIndexer.schedule('update_document', outfit)
    end

    products.each do |product|
      # Update all products with this occasion
      Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
      Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id)
    end
  end
end

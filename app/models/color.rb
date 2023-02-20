class Color < ActiveRecord::Base

  # Associations
  has_many :product_colors
  has_many :products, :through => :product_colors

  # Attachments
  has_attached_file :picture,
  styles: {  original: ["26X26#"], large: ["48x48#"] }

  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size

  def update_es_index
    self.reload
    products.each do |product|
      # Update all products with this color
      Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
      Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id)
    end
  end

  def background_css
    picture.exists? ?
      "background-image: url(#{picture.url(:original)})" :
      "background-color: #{code}; #{code == "#FFFFFF" ? "border: #e6e6e6 1px solid;" : ""}"
  end

end

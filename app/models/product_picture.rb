class ProductPicture < ActiveRecord::Base

  PICTURE_STYLE_OPTIONS = {
    png: {
      original: {
        geometry: "768x1024",
        convert_options: "-background transparent -gravity center -extent 768x1024"
      },
      medium: {
        geometry: "248x330",
        convert_options: "-background transparent -gravity center -extent 248x330"
      },
      thumb: {
        geometry: "120x160",
        convert_options: "-background transparent -gravity center -extent 120x160"
      }
    },
    jpg: {
      original: {
        geometry: "768x1024",
        convert_options: "-background white -gravity center -extent 768x1024"
      },
      medium: {
        geometry: "248x330",
        convert_options: "-background white -gravity center -extent 248x330"
      },
      thumb: {
        geometry: "120x160",
        convert_options: "-background white -gravity center -extent 120x160"
      }
    }
  }

  # Relations
  belongs_to :product
  belongs_to :color
  has_many   :outfit_product_pictures, dependent: :restrict_with_error

  # Attachments
  # '#' symbol will fit the image inside the dimensions and crop the rest
  # explanation here: http://stackoverflow.com/questions/7054606/difference-between-and-in-paperclip-styles-for-image
  has_attached_file :picture,
    :styles => lambda { |attachment| attachment.instance.decide_styles },
    url: Modules::SeoFriendlyAttachment.url,
    default_url: Conf.product.picture_default_path

  before_post_process :rename_file_name

  # Validations
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, less_than: Conf.attachment.max_file_size
  validates_numericality_of :order_index, greater_than_or_equal_to: 0, allow_blank: true
  validate  :presence_of_color_if_not_single

  # Callbacks
  before_save     :set_index
  after_commit    :update_product_index, on: [:create, :update, :destroy]
  after_commit    :open_graph_clear_cache

  def update_product_index
    Modules::DelayedJobs::EsIndexer.schedule('update_document', product)
    Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id) if product.present?
  end

  def decide_styles
    if self.picture_content_type == "image/png"
      PICTURE_STYLE_OPTIONS[:png]
    else
      PICTURE_STYLE_OPTIONS[:jpg]
    end
  end

protected

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, picture, product.name.parameterize + (color.blank? ? '' : "-#{color.name.parameterize}"))
  end

  def set_index
    if self.order_index.nil?
      max_index = ProductPicture.where(product_id: self.product_id).maximum(:order_index)
      self.order_index = 1 + (max_index || 0)
    end
    true
  end

  def open_graph_clear_cache
    Modules::OpenGraph.clear_cached_pages(product)
  end

  def presence_of_color_if_not_single
    if color.blank? && product.product_colors.size > 1
      errors.add(:color_id, "трябва да бъде избран")
    end
  end

end

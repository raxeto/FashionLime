class ProductCollection < ActiveRecord::Base

  # Relations
  belongs_to :merchant
  belongs_to :season

  has_many :products, dependent: :restrict_with_error

  # Scopes
  scope :visible_products, -> (ids) { 
    Product.where("product_collection_id in (?)", ids).visible
  }

  scope :collection_display, -> {
    includes(:season, :merchant)
  }
  
  # Callbacks
  before_save  :update_url_path
  after_commit :open_graph_clear_cache, on: [:update]

  # Validations
  validates_presence_of     :name
  validates_presence_of     :season_id
  validates_presence_of     :year
  validates_numericality_of :year, :greater_than => 2000

  # Attachments
  has_attached_file :picture,
  styles: {  original: ["996x547#"], medium: ["410x225#"] },
    url: Modules::SeoFriendlyAttachment.url,
    default_url: Conf.product_collection.picture_default_path

  before_post_process :rename_file_name

  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size

  def full_name
     name + ' ' + (season.try(:name) || '') + ' ' + year.to_s
  end

  def is_visible?
    merchant.active?
  end

  def to_client_param
    "#{url_path}-#{id}"
  end

  private 

  def update_url_path
    self.url_path = name.parameterize
    true
  end

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, picture, full_name.parameterize)
  end

  def open_graph_clear_cache
    Modules::OpenGraph.clear_cached_pages(self)
  end

end

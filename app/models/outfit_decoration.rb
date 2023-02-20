class OutfitDecoration < ActiveRecord::Base

  # Attributes
  enum category: { frame: 1, doodle: 2, graphic: 3, image: 4 }

  # Attachments
  has_attached_file :picture,
    styles: {
      original: ["768x768#"],
      thumb: ["95x95#"] },
    url: Modules::SeoFriendlyAttachment.url

  # Relations
  belongs_to :parent, class_name: "OutfitDecoration"
  has_many   :children, -> { order(:order_index) }, class_name: "OutfitDecoration", foreign_key: "parent_id"

  # Validations
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, less_than: Conf.attachment.max_file_size
  validates_numericality_of :order_index, greater_than_or_equal_to: 1

  public

  def self.from_category(c)
    Modules::OutfitDecorationJsonBuilder.instance.outfit_decorations_partial_data(
      OutfitDecoration.where(:category => OutfitDecoration.categories[c], :parent_id => nil).order(:order_index)
    )
  end

end

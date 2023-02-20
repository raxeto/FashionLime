class Campaign < ActiveRecord::Base

  # Attachments
  has_attached_file :picture,
    styles: {  original: ["1200x628#"], medium: ["400x209#"]},
    url: Modules::SeoFriendlyAttachment.url

  before_post_process :rename_file_name

  # Relations
  has_many   :campaign_objects, dependent: :destroy

  # Validations
  validates_presence_of :title
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, less_than: Conf.attachment.max_file_size

  # Callbacks
  before_save  :update_url_path

  def object_ids(object_type)
    campaign_objects.select { |o| o.object_type == object_type }.sort_by { |o| o[:order_index] }.map { |o| o.object_id }
  end

  def to_client_param
    "#{url_path}-#{id}"
  end

  private

  def update_url_path
    self.url_path = title.parameterize
    true
  end

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, picture, self.title.parameterize)
  end

end

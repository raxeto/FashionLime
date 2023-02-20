class ShipmentType < ActiveRecord::Base

  # Attachments
  has_attached_file :picture # Recommended size is 90px in height

  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size
  
end

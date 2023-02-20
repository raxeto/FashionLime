class OpenGraphTag < ActiveRecord::Base

   # Attachments
  has_attached_file :picture,
    styles: {  
      original: {}
    }, 
    url: Modules::SeoFriendlyAttachment.url

  # Validations
  validates_presence_of :page_link
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size

end

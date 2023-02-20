class HomePageLink < ActiveRecord::Base

  # Attributes
  enum position: { in_list: 1, main: 2 }
  has_attached_file :picture,
    styles: {  
      original: ["1200x628#"],
      medium: ["600x314#"] 
    }, 
    url: Modules::SeoFriendlyAttachment.url

  before_post_process :rename_file_name

  # Validations
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size

  private

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, picture, self.title.parameterize)
  end

end

class BlogPost < ActiveRecord::Base

  # Relations
  belongs_to  :user

  # Attachments
  has_attached_file :main_picture,
    styles: {  
      # Recommended ratio 16:9 (1.777)
      original: {}, # Best size for the original picture 900x507. It's saved in its original dimensions.
      medium: ["300x169#"] 
    }, 
    url: Modules::SeoFriendlyAttachment.url

  # Validations
  validates_presence_of :title
  validates_presence_of :text
  validates_presence_of :user
  validates_presence_of :source_title, :if => Proc.new { |p| p.source_link.present? }
  validates_presence_of :source_link, :if => Proc.new { |p| p.source_title.present? }
  validates_attachment_content_type :main_picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :main_picture, :less_than => Conf.attachment.max_file_size
  validates_presence_of :main_picture_width, :if => Proc.new { |p| p.main_picture.present? }
  validates_presence_of :main_picture_height, :if => Proc.new { |p| p.main_picture.present? }

  # Calsbacks
  before_post_process :rename_file_name
  before_save  :update_url_path

  def intro
    subtitle.presence || text.truncate(160, :separator => '.')
  end

  def related_blog_posts
    BlogPost.where("id != #{self.id}").
    order(created_at: :desc).
    includes(:user).
    limit(Conf.blog_post.related_blog_posts_count)
  end

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, main_picture, title.parameterize)
  end

  def update_url_path
    url = Modules::StringLib.unicode_downcase(title).gsub(' ', '-')
    self.url_path = url
    true
  end

end

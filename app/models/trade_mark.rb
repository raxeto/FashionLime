class TradeMark < ActiveRecord::Base

  # Relations
  has_many :products, dependent: :restrict_with_error


  attr_accessor :logo

  # Attachments
  has_attached_file :logo,
  styles: {  original: ["120x120#"], thumb: ["32x32#"] },
  default_url: Conf.attachment.missing_file_path

  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :logo, :less_than => Conf.attachment.max_file_size

end

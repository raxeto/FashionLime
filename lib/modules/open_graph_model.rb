module Modules
  module OpenGraphModel

    def self.included(base)
      base.send :has_attached_file, :og_image, {styles: {  original: ["#{Conf.attachment.facebook_recommended_size}#"] }}
      base.send :validates_attachment_content_type, :og_image, { content_type: /\Aimage\/.*\Z/ }
      base.send :validates_attachment_size, :og_image, {less_than: Conf.attachment.max_file_size}
    end

    def self.default_image_width
      Modules::PictureLib.image_width_from_geometry(Conf.attachment.facebook_recommended_size)
    end

    def self.default_image_height
      Modules::PictureLib.image_height_from_geometry(Conf.attachment.facebook_recommended_size)
    end

  end
end

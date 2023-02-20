module Modules
  module SeoFriendlyAttachment

    def self.url
      "/system/:class/:id/:attachment/:style/:filename"
    end

    # This is normaly called from before_post_process callback of Paperclip
    # All parameters that are going to be used in the filename has to be set before the attachment
    # In params array for example. In product pictures when we call ProductPicture.create(params)
    # In params the product_id has to be set before the picture - otherwise the product will be nil
    def self.set_file_name(model, attachment, new_file_name)
      extension = File.extname(model[attachment.name.to_s + "_file_name"]).downcase
      attachment.instance_write :file_name, "#{new_file_name}#{extension}"
    end

  end
end

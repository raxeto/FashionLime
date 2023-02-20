class ApplicationMailer < ActionMailer::Base
  
  include Modules::CurrencyLib
  include Modules::NumberLib
  include Modules::StringLib
  include Modules::DateLib
  include Modules::PictureLib
  include Modules::ClientUrlLib

  include Roadie::Rails::Automatic

  helper SeoFriendlyImageHelper
  helper MailerHelper

  helper_method :products_url, :product_url,
                :outfit_url, :outfits_url, :product_collection_url,
                :search_page_url, :return_order_url, 
                :date_to_s, :date_time_to_s,
                :image_width, :image_height

  default from: "no-reply@fashionlime.bg"
  layout 'mailer'

end

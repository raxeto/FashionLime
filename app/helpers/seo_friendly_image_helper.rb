module SeoFriendlyImageHelper
 
  def product_picture_image(product_picture, picture_style, options = {})
    url = product_picture.nil? ? Product::DefaultProductPicture.new.url(picture_style) : product_picture.picture.url(picture_style)
    seo_image(url, seo_image_description(:product_picture, product_picture), options)
  end

  def outfit_image(outfit, picture_style, options = {})
    url = outfit.picture.url(picture_style)
    seo_image(url, seo_image_description(:outfit, outfit), options)
  end

  def user_image(user, picture_style, options = {})
    url = user.avatar.url(picture_style)
    seo_image(url, seo_image_description(:user, user), options)
  end

  def merchant_image(merchant, picture_style, options = {})
    url = merchant.logo.url(picture_style)
    seo_image(url, seo_image_description(:merchant, merchant), options)
  end

  def product_collection_image(product_collection, picture_style, options = {})
    url = product_collection.picture.url(picture_style)
    seo_image(url, seo_image_description(:product_collection, product_collection), options)
  end

  def campaign_image(campaign, picture_style, options = {})
    url = campaign.picture.url(picture_style)
    seo_image(url, seo_image_description(:campaign, campaign), options)
  end

  def payment_type_image(payment_type, options = {})
    url = payment_type.picture.url(:original)
    options[:height] = options[:height] || 45
    seo_image(url, seo_image_description(:payment_type, payment_type), options)
  end

  def shipment_type_image(shipment_type, options = {})
    url = shipment_type.picture.url(:original)
    options[:height] = options[:height] || 45
    seo_image(url, seo_image_description(:shipment_type, shipment_type), options)
  end

  def blog_post_image(blog_post, picture_style, options = {})
    url = blog_post.main_picture.url(picture_style)
    seo_image(url, seo_image_description(:blog_post, blog_post), options)
  end

  def home_page_link_image(home_page_link, picture_style, options = {})
    url = home_page_link.picture.url(picture_style)
    seo_image(url, seo_image_description(:home_page_link, home_page_link), options)
  end

  def seo_image_description(type, model)
    case type
    when :product_picture
      if !model.nil? 
        occasion_names = model.product.occasion_names
        "#{model.product.name} от #{model.product.merchant.name}#{model.color.blank? ? '' : ", цвят #{Modules::StringLib.unicode_downcase(model.color.name)}"}"\
        "#{occasion_names.present? ? ", тип облекло #{Modules::StringLib.unicode_downcase(occasion_names.to_sentence)}" : ""}."
      else
        "Продукт без добавена картинка"
      end
    when :outfit
      if model.picture.present?
        product_names = model.product_names
        occasion_names = model.occasion_names
          "Визия #{model.name} от #{model.profile.name},"\
          " съставена от #{Modules::StringLib.unicode_downcase(I18n.t('activerecord.models.product', :count => product_names.length))}: #{product_names.to_sentence},"\
          " тип облекло: #{Modules::StringLib.unicode_downcase(occasion_names.to_sentence)}." 
      else
        "Визия без генерирана снимка"
      end
    when :outfit_decoration
      "Декорация за визия - #{Modules::StringLib.unicode_downcase(model.category_i18n)}"
    when :user
      model.avatar.present? ? 
        "Профилна снимка на #{model.username} във Fashion Lime" : 
        "Потребител без качена профилна снимка"
    when :merchant
      model.logo.present? ? 
        "Лого на #{model.name} във Fashion Lime" : 
        "Търговец без качено лого"
    when :product_collection
      model.picture.present? ? 
        "#{model.full_name} от #{model.merchant.name}" : 
        "Колекция от продукти без качена снимка"
    when :payment_type
      "Снимка към начин на плащане #{model.name}"
    when :shipment_type
      "Снимка към начин на доставка #{model.name}"
    when :blog_post
      "Снимка към статия със заглавие #{model.title}"
    when :campaign
      "Снимка към кампания #{model.title}"
    when :home_page_link
      "Снимка към секция #{model.title}"
    else
      ""
    end
  end

  def seo_image(url, alt_text, options)
    image_tag url, options.merge(:alt => alt_text)
  end
  
end

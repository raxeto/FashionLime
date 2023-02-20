class PromotionMailer < ApplicationMailer
  
  def promotion_email(email, subject, message_html, message_text, product_collection_ids, outfit_ids, product_ids, query_params, unsubscribe_url)
    c_ids = Modules::StringLib.to_number_array(product_collection_ids)
    o_ids = Modules::StringLib.to_number_array(outfit_ids)
    p_ids = Modules::StringLib.to_number_array(product_ids)
    @message_html = message_html.try(:html_safe)
    @message_text = message_text
    @product_collections = ProductCollection.includes(:merchant, :season).where(:id => c_ids).sort_by { |c| c_ids.index(c.id) }
    @outfits = Outfit.includes(:outfit_category, profile: [:owner]).where(:id => o_ids).limit(8).sort_by { |o| o_ids.index(o.id) }
    @products = Product.includes(:merchant, :product_pictures).where(:id => p_ids).limit(8).sort_by { |p| p_ids.index(p.id) }
    @query_params = query_params
    @unsubscribe_url = unsubscribe_url
    mail(to: email, subject: subject)
  end

end

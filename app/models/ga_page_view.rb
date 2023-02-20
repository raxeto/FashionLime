class GaPageView < ActiveRecord::Base

  # Relations
  belongs_to :related_model, polymorphic: true
  belongs_to :user

  def self.merchant_products_last_days_count(merchant_id, days)
    query = GaPageView.joins(
      "join products on products.id = ga_page_views.related_model_id
        and ga_page_views.related_model_type = 'Product'").
       where("products.merchant_id = ?", merchant_id)

    merchant_model_last_days_count(query, merchant_id, days)
  end

  def self.merchant_outfits_last_days_count(merchant_id, days)
    merchant = Merchant.find_by_id(merchant_id)
    if merchant.nil?
      return 0
    end
    query = GaPageView.joins(
      "join outfits on outfits.id = ga_page_views.related_model_id
        and ga_page_views.related_model_type = 'Outfit'").
       where("outfits.profile_id = ?", merchant.profile.id)

    merchant_model_last_days_count(query, merchant_id, days)
  end

  def self.merchant_profile_last_days_count(merchant_id, days)
    query = GaPageView.
       where("ga_page_views.related_model_id = ? and ga_page_views.related_model_type = 'Merchant'", merchant_id)

    merchant_model_last_days_count(query, merchant_id, days)
  end

  def self.merchant_model_last_days_count(basic_query, merchant_id, days)
    basic_query.where("date(ga_page_views.view_date) between ? and ?", Time.zone.today - (days - 1), Time.zone.today).sum("ga_page_views.page_views")
  end
  
end

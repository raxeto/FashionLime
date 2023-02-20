class CampaignsController < ClientController

  append_before_filter :load_campaign, only: [:show]
  append_before_filter :load_campaign_by_id, only: [:load_more_products, :load_more_outfits]

  include Modules::FilteredProducts
  include Modules::FilteredOutfits

  def show
    add_breadcrumb @campaign.title
    @products = load_campaign_products(@campaign)
    @outfits = load_campaign_outfits(@campaign)
  end

  def load_more_products
    @products = load_campaign_products(@campaign)
    render json: [@products.map(&:html_safe)]
  end

  def load_more_outfits
    @outfits = load_campaign_outfits(@campaign)
    render json: [@outfits.map(&:html_safe)]
  end

  private

  def load_campaign
    c = params[:campaign]
    last_dash = c.rindex('-')
    if last_dash.nil? || (campaign_id = c.from(last_dash + 1).to_i) == 0
      redirect_to root_path, alert: "Кампанията, който търсите, не бе намерена."
      return
    end
    @campaign = Campaign.includes(:campaign_objects).find_by_id(campaign_id)
    try_redirect_campaign(@campaign)
  end

  def load_campaign_by_id
    campaign_id = params[:campaign_id]
    @campaign = Campaign.includes(:campaign_objects).find_by_id(campaign_id)
  end

  def load_campaign_products(campaign)
    product_ids = campaign_products(campaign)
    if product_ids.size > 0
      return search_products(Conf.search.initial_item_count, { :products => product_ids, :sort_by_ids => product_ids })
    else
      return []
    end
  end

  def campaign_products(campaign)
    campaign.object_ids('Product')
  end

  def load_campaign_outfits(campaign)
    outfit_ids = campaign_outfits(campaign)
    if outfit_ids.size > 0
      return search_outfits(Conf.search.initial_item_count, { :outfits => outfit_ids, :sort_by_ids => outfit_ids })
    else
      return []
    end
  end

  def campaign_outfits(campaign)
    campaign.object_ids('Outfit')
  end

  def try_redirect_campaign(campaign)
    not_found_msg = "Кампанията, който търсите, не бе намерена."
    if campaign.nil?
      redirect_to root_path, :status => 301, :alert => not_found_msg
      return
    end
    if remove_marketing_params(request.fullpath) != campaign_path(campaign)
      redirect_to campaign_path(campaign), :status => 301
      return
    end
  end

end

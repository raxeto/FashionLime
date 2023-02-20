class Admin::CampaignsController < AdminController

  include Modules::ClientControllerLib
  include Modules::FilteredProducts
  include Modules::FilteredOutfits

  append_before_filter :load_campaign, only: [:new_outfits, :create_outfits]

  def index
    @campaigns = Campaign.includes(:campaign_objects).order(created_at: :desc)
  end

  def new
    @campaign = Campaign.new
    @selected_products = nil
    @products = search_products(Conf.search.initial_item_count, {})
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @selected_products = params[:selected_products]
    @products = search_products(Conf.search.initial_item_count, {})

    error = ""
    ind = 1

    Modules::StringLib.to_number_array(@selected_products).each do |p|
      product = Product.find_by_id(p)
      if product.nil?
        error << "Продукт с ID: #{p} не бе открит. "
      else
        puts "order index is #{ind}"
        @campaign.campaign_objects.build({ :object => product, :order_index => ind })
      end
      ind = ind + 1
    end

    if error.blank?
      unless @campaign.save
        render :new
        return
      end
      redirect_to admin_campaigns_path, notice: 'Campaign created successfully!'
    else
      flash.now[:alert] = error
      render :new
    end
  end

  def load_more_products
    @products = search_products(Conf.search.initial_item_count, {})
    render json: [@products]
  end

  def new_outfits
    @selected_outfits = nil
    @outfits = search_outfits(Conf.search.initial_item_count, {})
  end

  def create_outfits
    @selected_outfits = params[:selected_outfits]
    @outfits = search_outfits(Conf.search.initial_item_count, {})

    error = ""
    ind = 1

    Modules::StringLib.to_number_array(@selected_outfits).each do |o|
      outfit = Outfit.find_by_id(o)
      if outfit.nil?
        error << "Визия с ID: #{o} не бе открита. "
      else
        @campaign.campaign_objects.build({ :object => outfit, :order_index => ind })
      end
      ind = ind + 1
    end

    if error.blank?
      unless @campaign.save
        render :new_outfits
        return
      end
      redirect_to admin_campaigns_path, notice: 'Outfits added to campaign successfully!'
    else
      flash.now[:alert] = error
      render :new_outfits
    end
  end

  def load_more_outfits
    @outfits = search_outfits(Conf.search.initial_item_count, {})
    render json: [@outfits]
  end

  def destroy
    if Campaign.destroy(params[:id])
      redirect_to admin_campaigns_path, notice: 'Campaign destroyed successfully!'
    else 
      redirect_to admin_campaigns_path, alert: 'Campaign was not destroyed!'
    end
  end

  def load_campaign
    @campaign = Campaign.find_by_id(params[:id])
    if @campaign.blank?
      redirect_to admin_campaigns_path, notice: "Кампанията не е намерена."
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title, :description, :picture)
  end

end

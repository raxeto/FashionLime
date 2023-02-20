class Admin::HomePageVariantsController < AdminController

  def index
    @variants = HomePageVariant.includes(:home_page_objects).order(created_at: :desc)
  end

  def new
    @variant = HomePageVariant.new
  end

  def create
    @variant = HomePageVariant.new
    @home_page_links = params[:home_page_links]
    @product_collections = params[:product_collections]
    @outfits = params[:outfits]
    @merchants = params[:merchants]
    @products = params[:products]

    error = ""
    ind = 1

    Modules::StringLib.to_number_array(@home_page_links).each do |l|
      link = HomePageLink.find_by_id(l)
      if link.nil?
        error << "Home page link с ID: #{l} не бе открит."
      else
        @variant.home_page_objects.build({ :object => link, :order_index => ind })
      end
      ind = ind + 1
    end

    ind = 1

    Modules::StringLib.to_number_array(@product_collections).each do |c|
      collection = ProductCollection.find_by_id(c)
      if collection.nil?
        error << "Колекция с ID: #{c} не бе открита. "
      else
        puts "order index is #{ind}"
        @variant.home_page_objects.build({ :object => collection, :order_index => ind })
      end
      ind = ind + 1
    end

    ind = 1

    Modules::StringLib.to_number_array(@outfits).each do |o|
      outfit = Outfit.find_by_id(o)
      if outfit.nil?
        error << "Визия с ID: #{o} не бе открита. "
      else
        @variant.home_page_objects.build(:object => outfit, :order_index => ind)
      end
      ind = ind + 1
    end

    ind = 1

    Modules::StringLib.to_number_array(@merchants).each do |m|
      merchant = Merchant.find_by_id(m)
      if merchant.nil?
        error << "Търговец с ID: #{m} не бе открит. "
      else
        @variant.home_page_objects.build(:object => merchant, :order_index => ind)
      end
      ind = ind + 1
    end

    ind = 1

    Modules::StringLib.to_number_array(@products).each do |p|
      product = Product.find_by_id(p)
      if product.nil?
        error << "Продукт с ID: #{p} не бе открит. "
      else
        @variant.home_page_objects.build(:object => product, :order_index => ind)
      end
      ind = ind + 1
    end

    if error.blank?
      unless @variant.save
        render :new
        return
      end
      redirect_to admin_home_page_variants_path, notice: 'Home page variant  created successfully!'
    else
      flash.now[:alert] = error
      render :new
    end
  end

  def destroy
    if HomePageVariant.destroy(params[:id])
      redirect_to admin_home_page_variants_path, notice: 'Home Page Variant destroyed successfully!'
    else 
      redirect_to admin_home_page_variants_path, alert: 'Home Page Variant was not destroyed!'
    end

  end

end

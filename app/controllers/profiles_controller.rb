class ProfilesController < ClientController

  append_before_filter :load_merchant, only: [:show_merchant, :product_collections, :product_collection, :products, :load_more_products, :merchant_outfits, :load_more_merchant_outfits]
  append_before_filter :load_user, only: [:show_user, :user_outfits, :load_more_user_outfits, :user_favorite_products, :load_more_user_favorite_products]
  append_before_filter :load_favorite_products, only: [:show_user, :user_favorite_products, :load_more_user_favorite_products]

  include Modules::FilteredProducts
  include Modules::FilteredOutfits

  def show_merchant
    collection_ids = @merchant.product_collections.joins(:season).order("year desc, seasons.order_index asc, product_collections.created_at desc").ids.first(Conf.profiles.visible_collections_count)
    @collections = ProductCollection.where(:id => collection_ids).includes(:season)
    @collections = @collections.sort_by { |c| collection_ids.index(c.id) }
    @collections_cnt = collection_ids.length

    @products = Modules::ProductJsonBuilder.instance.products_partial_data(
      Product.visible.where(merchant_id: @merchant.id).order(rating: :desc, created_at: :desc).first(Conf.profiles.visible_products_count), 
      current_profile.id
    ) 
    @products_cnt = @products.length

    @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
      Outfit.visible.where("merchants.id = ?", @merchant.id).order(rating: :desc, created_at: :desc).first(Conf.profiles.visible_merchant_outfits_count),
      current_or_guest_user
    )

    @outfits_cnt = @outfits.length
  end

  def show_user
    @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
      Outfit.visible.where("outfits.user_id = ?", @user.id).order(rating: :desc, created_at: :desc).first(Conf.profiles.visible_user_outfits_count),
      current_or_guest_user
    )
    @products = Modules::ProductJsonBuilder.instance.products_partial_data(
      Product.where(id: @product_ids).order(rating: :desc, created_at: :desc).first(Conf.profiles.visible_user_favorite_products_count),
      current_profile.id
    ) 
  end

  # Merchant profile functions
  def product_collections
    add_breadcrumb "Колекции", merchant_profile_product_collections_path(:url_path => @merchant.url_path)
    @sections = [:profile_collections, :products]
    @product_collections = @merchant.product_collections.joins(:season).order("year desc, seasons.order_index asc, product_collections.created_at desc").includes(:season)
  end

  def product_collection
    url_collection = params[:collection]
    last_dash = url_collection.rindex('-')
    if last_dash.nil? || (collection_id = url_collection.from(last_dash + 1).to_i) == 0
      redirect_to merchant_profile_product_collections_path(:url_path => @merchant.url_path), alert: "Грешен линк към колекция."
      return
    end
    @sections = [:profile_collection, :products]
    @collection = ProductCollection.includes(:merchant).find_by_id(collection_id)
    return if try_redirect_collection(@collection)
    add_breadcrumb @collection.name, product_collection_path(@collection)
    @products = Modules::ProductJsonBuilder.instance.products_partial_data(ProductCollection.visible_products(@collection.id), current_profile.id) 
  end

  def products
    load_products_from_search({ :merchants => [@merchant.id] })
  end

  def load_more_products
    load_more_products_from_search({ :merchants => [@merchant.id] })
  end

  def merchant_outfits
    load_outfits_from_search(@merchant.profile)
  end

  def load_more_merchant_outfits
    load_more_outfits_from_search(@merchant.profile)
  end

  def user_outfits
    load_outfits_from_search(@user.profile)
  end

  def load_more_user_outfits
    load_more_outfits_from_search(@user.profile)
  end

  def user_favorite_products
    load_products_from_search({ :products => @product_ids })
  end

  def load_more_user_favorite_products
    load_more_products_from_search({ :products => @product_ids })
  end

  private

  def load_products_from_search(search_params)
    if @merchant.present?
      add_breadcrumb "Продукти", merchant_profile_products_path(:url_path => @merchant.url_path), title: "Продукти на #{@merchant.name}"
    else
      add_breadcrumb "Любими продукти", user_profile_favorite_products_path(:url_path => @user.url_path)
    end
    @sections = [:profile_products, :favorite_products, :products]
    @products = search_products(Conf.search.initial_item_count, search_params)
    render :products
  end

  def load_more_products_from_search(search_params)
    @products = search_products(Conf.search.initial_item_count, search_params)
    render json: [@products.map(&:html_safe)]
  end

  def load_outfits_from_search(profile)
    add_breadcrumb "Визии"
    @sections = [:profile_outfits, :outfits]
    @outfits = search_outfits(Conf.search.initial_item_count, { :profile_id => profile.id })
    render :outfits
  end

  def load_more_outfits_from_search(profile)
    @outfits = search_outfits(Conf.search.initial_item_count, { :profile_id => profile.id })
    render json: [@outfits.map(&:html_safe)]
  end

  def load_merchant
    # Show profiles only on active merchants
    @merchant = Merchant.active.find_by url_path: params[:url_path]
    unless @merchant.nil?
      add_breadcrumb @merchant.name, merchant_profile_path(@merchant.url_path)
    end
    redirect_if_nil(@merchant)
  end

  def load_user
    @user = User.find_by url_path: params[:url_path]
    if @user && @user.merchant?
      redirect_to merchant_profile_path(@user.merchant.url_path)
    else
      if @user && !@user.active?
        @user = nil
      end
      unless @user.nil?
        add_breadcrumb @user.username, user_profile_path(@user.url_path)
      end
      redirect_if_nil(@user)
    end
  end

  def load_favorite_products
    product_ids = @user.profile.ratings.where("owner_type = 'Product' and rating > 0").pluck(:owner_id)
    @product_ids = Product.where(id: product_ids).visible.ids
  end

  def redirect_if_nil(model)
    if model.nil?
      redirect_to root_path, :status => 301, alert: "Профилът е недостъпен или не съществува."
    end
  end

  def try_redirect_collection(collection)
    not_found_msg = "Колекцията, която търсите, не бе намерена."
    if collection.nil? || !collection.is_visible?
      redirect_to merchant_profile_product_collections_path(:url_path => @merchant.url_path), alert: not_found_msg
      return true
    end
    if remove_marketing_params(request.fullpath) != product_collection_path(collection)
      redirect_to product_collection_path(@collection), :status => 301
      return true
    end
    return false
  end

  def sections
    if @sections.nil?
      []
    else
      @sections
    end
  end

end

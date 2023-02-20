class ProductsController < ClientController

  append_before_filter :load_product, only: [:sizes_for_color]
  helper_method :expand_category?, :category_path, :category_text, :has_children?, :category_children

  include Modules::FilteredProducts

  def show_all
    show_product_or_category
  end

  def show_category
    show_product_or_category
  end

  def show_product_or_category
    @category = nil
    @product = nil
    cat_param = params[:category]
    subcat_prod_param = params[:subcategory_or_product]

    unless cat_param.blank?
      # includes in order to optimize deep_find_child_by_url_path
      # otherwise there are too many calls on product show
      @category = ProductCategory.children_from_key('outfit').includes(children: [children: [:children]]).find_by url_path: cat_param
      if @category.nil?
        redirect_category(@category)
        return
      end
    end

    unless subcat_prod_param.blank?
      subcategory = @category.deep_find_child_by_url_path(subcat_prod_param)
      if subcategory.nil?
        last_dash = subcat_prod_param.rindex('-')
        if last_dash.nil? || (product_id = subcat_prod_param.from(last_dash + 1).to_i) == 0
          redirect_category(@category)
          return
        else
          load_product_details(product_id)
          return if try_redirect_product(@product, @category)
          load_product_default_color_size
          show
          return
        end
      else
        @category = subcategory
      end
    end

    override_params = {}
    if @category.nil?
      add_breadcrumb "Продукти"
    else
      add_category_breadcrumbs(@category)
      override_params[:c] = @category.key
    end
    dt_start = Time.now
    @products = search_products(Conf.search.initial_item_count, override_params)
    Rails.logger.info("**** Search products time #{(Time.now - dt_start) * 1000.0} ms.")

    @categories = categories_for_menu(@category)
    @track_categories = categories_for_tracking(@category)
    render :index
  end

  def show
    add_category_breadcrumbs(@product.product_category)
    add_breadcrumb "Продукт"
    render :show
  end

  def load_more_products
    override_params = {}
    if params[:category_id].to_i > 0
      category = ProductCategory.find_by_id params[:category_id]
      unless category.nil?
        override_params[:c] = category.key
      end
    end
    @products = search_products(Conf.search.initial_item_count, override_params)
    render json: [@products]
  end

  def sizes_for_color
    color = Color.find_by_id(params[:color])
    if @product.nil? || color.nil?
      render json: { status: false, error: "Продуктът е недостъпен."}
      return
    end
    render json: @product.active_sizes_and_prices_for_color(color)
  end

  def add_to_cart
    load_product_details(params[:id])

    # The product visibility or status has changed
    if @product.nil? || !@product.is_visible?
      redirect_to root_path, alert: "Продуктът е недостъпен."
      return
    end
    if @product.not_active?
      redirect_to product_path(@product)
      return
    end

    pars = params.permit(:id, :color_id, :size_id, :qty)
    @color_id = pars[:color_id].to_i
    @size_id  = pars[:size_id].to_i
    prev_total = current_cart.total_with_discount

    alert_msg = ""
    notice_msg = ""

    if (@color_id == 0 || @size_id == 0)
      alert_msg = "Моля изберете размер и цвят."
    else
      article = @product.articles.where(color_id: @color_id, size_id: @size_id).take
      if article.nil?
        alert_msg = "Артикулът вече не съществува."
      else
        begin
          current_cart.add_article(article, pars[:qty].to_d)
          notice_msg = "Артикулът беше добавен в количката Ви."
        rescue StandardError => e
          alert_msg = e.message
        end
      end
    end

    if notice_msg.present?
      flash[:products_added_to_cart] = {:ids => [@product.id], :value => current_cart.total_with_discount - prev_total}
      redirect_to cart_show_path, notice: notice_msg
    else
      flash.now[:alert] = alert_msg
      show
    end
  end

protected

  def sections
    [:products]
  end

  def expand_category?(category, selected_category) 
    if selected_category.nil?
      return category.parent.key == "outfit"
    end
    Modules::ProductCategoryCache.all_category_ids_for_category_id(category.id).include?(selected_category.id)
  end

  def category_path(category)
    if category.key == "men"  || (category.parent.present? && category.parent.key == "men")
      "#"
    else
      products_path(:c => category.key)
    end
  end

  def category_text(category)
    category.name
  end

  def has_children?(category)
    category.visible_children.size > 0
  end

  def category_children(category)
    category.visible_children
  end

private

  def load_product
    @product = Product.visible.includes(:articles).find_by_id(params[:id])
  end

  def load_product_details(product_id)
    @product = Product.includes(:occasions, product_pictures: [:color, product: [:merchant, :occasions]], articles: [:color, :size]).find_by_id(product_id)
    if @product.present?
      @merchant = Merchant.includes(:merchant_shipments).find_by_id(@product.merchant_id)
      @colors = @product.colors_sort_by_pictures
      @sizes = @product.active_sizes
      @related_products = Modules::ProductJsonBuilder.instance.products_partial_data(@product.related_products, current_profile.id) 
      @suitable_products = Modules::ProductJsonBuilder.instance.products_partial_data(@product.suitable_products, current_profile.id) 
    end
  end

  def load_product_default_color_size
    color = @colors.size > 0 ? @colors[0] : nil
    @color_id = color.try(:id) || 0
    @size_id = color.present? ? @product.active_sizes_for_color(color).first.try(:id) || 0 : 0
  end

  def try_redirect_product(product, master_category)
    not_found_msg = "Продуктът, който търсите, не бе намерен."
    if product.nil?
      if master_category.nil?
        redirect_to products_path, :status => 301, :alert => not_found_msg
      else
        redirect_to products_path(:c => master_category.key), :status => 301, :alert => not_found_msg
      end
      return true
    elsif !product.is_visible?
      redirect_to products_path(:c => product.product_category.key), :status => 301, :alert => not_found_msg
      return true
    end
    if remove_marketing_params(request.fullpath) != product_path(product)
      redirect_to product_path(product), :status => 301
      return true
    end
    return false
  end

  def redirect_category(category)
    not_found_msg = "Категорията продукти, която търсите, не бе намерена."
    if category.nil?
      redirect_to products_path, :status => 301, :alert => not_found_msg
    else
      redirect_to products_path(:c => category.key), :status => 301, :alert => not_found_msg
    end
  end

  def categories_for_menu(category)
    if category.nil?
      return ProductCategory.children_from_key('outfit').to_a
    end
    main_category = category.parent
    while main_category.parent.present? && main_category.parent.key != 'outfit'
      main_category = main_category.parent
    end
    return main_category.children.sort_by { |c| c[:order_index] }
  end

  def categories_for_tracking(category)
    if category.nil?
      return []
    end
    ret = []
    excluded_categories = ['outfit', 'women', 'men']
    if !excluded_categories.include?(category.key)
      ret << category.key
    end
    if category.parent.present? && !excluded_categories.include?(category.parent.key)
      ret << category.parent.key
    end
    ret
  end

  def add_category_breadcrumbs(category)
    categories = []
    while !category.nil? do
      categories.push(category)
      break if category.key == 'men' || category.key == 'women'  # Men & Women last level to show
      category = category.parent
    end
    categories.reverse_each do |c|
      if c.key == 'men' || c.key == 'women'
        add_breadcrumb "Продукти #{c.name}", products_path(:c => c.key)
      else
        add_breadcrumb c.name, products_path(:c => c.key)
      end
    end
  end

end

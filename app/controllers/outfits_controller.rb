class OutfitsController < ClientController

  include Modules::FilteredProducts
  include Modules::FilteredOutfits

  helper_method :expand_category?, :category_path, :category_text, :has_children?, :category_children

  append_before_filter :load_products,        only: [:edit, :new, :create, :update]
  append_before_filter :load_outfit,          only: [:add_to_cart]
  append_before_filter :load_profile_outfits, only: [:update, :edit]

  add_breadcrumb "Визии", :outfits_path, only: [:edit, :new, :create, :update, :add_to_cart, :insert_to_cart, :my_outfits]
  add_breadcrumb "Създаване на визия", :new_outfit_path, only: [:new]
  add_breadcrumb "Редактиране на визия", :edit_outfit_path, only: [:edit]
  add_breadcrumb "Добавяне в количката", :add_to_cart_outfit_path, only: [:add_to_cart, :insert_to_cart]
  add_breadcrumb "Моите визии", :my_outfits_outfits_path, only: [:my_outfits]

  def show_all
    show
  end

  def show_outfit_or_occasion
    show
  end

  def show_category_or_product
    show
  end

  def show
    @category = nil
    @product = nil
    cat_param = params[:category_or_product]
    occ_outfit_param = params[:occasion_or_outfit]

    unless cat_param.blank?
      @category = OutfitCategory.find_by url_path: cat_param
      if @category.nil?
        last_dash = cat_param.rindex('-')
        if last_dash.nil? || (product_id = cat_param.from(last_dash + 1).to_i) == 0
          redirect_category
          return
        else
          @product = Product.find_by_id(product_id)
          return if try_redirect_product(@product)
          add_breadcrumb "Визии", :outfits_path
          add_breadcrumb "Визии за продукт"
          @outfits = search_outfits(Conf.search.initial_item_count, {:products => [@product.id] })
          render :product_outfits
          return
        end
      end
    end

    unless occ_outfit_param.blank?
      @occasion = Occasion.find_by url_path: occ_outfit_param
      if @occasion.nil?
        last_dash = occ_outfit_param.rindex('-')
        if last_dash.nil? || (outfit_id = occ_outfit_param.from(last_dash + 1).to_i) == 0
          redirect_occasion(@category)
          return
        else
          @outfit = Outfit.includes(:profile, outfit_product_pictures: [product_picture: [:product]]).find_by_id(outfit_id)
          return if try_redirect_outfit(@outfit, @category)
          @related_outfits =  Modules::OutfitJsonBuilder.instance.outfits_partial_data(@outfit.related_outfits, current_or_guest_user) 
          @picture_generated = @outfit.picture.present?
          add_category_breadcrumb(@outfit.outfit_category)
          add_breadcrumb "Визия"
          render :show
          return
        end
      end
    end

    override_params = {}
    if !@category.nil?
      add_category_breadcrumb(@category)
      override_params[:c] = @category.id
    else
      add_breadcrumb "Визии", :outfits_path
    end
    if !@occasion.nil?
      add_breadcrumb @occasion.name.pluralize(:bg)
      override_params[:occasions] = [@occasion.id]
    end
    @outfit_set = OutfitSet.find_by(:outfit_category => @category, :occasion => @occasion)
    @outfits = search_outfits(Conf.search.initial_item_count, override_params)
    @categories = categories_for_menu(@category)
    render :index
  end

  def load_more_outfits
    override_params = {}
    if params[:category_id].to_i > 0
      override_params[:c] = params[:category_id]
    end
    if params[:occasion_id].to_i > 0
      override_params[:occasions] = [params[:occasion_id]]
    end
    if params[:product_id].to_i > 0
      override_params[:products] = [params[:product_id]]
    end

    @outfits = search_outfits(Conf.search.initial_item_count, override_params)
    render json: [@outfits]
  end

  def my_outfits
    @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
      Outfit.where(profile_id: current_profile.id),
      current_or_guest_user
    )
  end

  def new
    @outfit = Outfit.new
    init_template_row()
  end

  def create
    @outfit = current_or_guest_user.outfits.build(outfit_params)
    if !@outfit.save
      init_template_row()
      render :new
      return
    end
    save_svg_to_png_picture(false)
    flash[:popup_share_after_create] = true
    flash[:outfit_just_created] = true
    redirect_to outfit_path(@outfit), notice: "Успешно създаване на визия."
  end

  def edit
    init_template_row()
  end

  def update
    if @outfit.update_attributes(outfit_params)
      save_svg_to_png_picture(true)
      redirect_to edit_outfit_path, notice: "Успешно редактиране."
    else
      init_template_row()
      render :edit
    end
  end

  def destroy
    @outfit = Outfit.find_by_id(params[:id])
    if @outfit.nil? || (@outfit.profile_id != current_profile.id && !current_user_admin?)
      render json: { status: false, error: "Визията не е намерена" }
      return
    end
    begin
      @outfit.destroy!()
      render json: { status: true }
    rescue ActiveRecord::ActiveRecordError
      render json: { status: false, error: @outfit.errors.full_messages }
    end
  end

  def add_to_cart
    @cart = Cart.new

    outfit_products = @outfit.products_thumb_data
    product_ids = outfit_products.map { |p| p[:product].id }.uniq
    products = Product.includes(:merchant, product_pictures: [:color, product: [:merchant]], articles: [:color, :size]).where(:id => product_ids)

    outfit_products.each do |op|
      product = products.select {|p| p.id == op[:product].id}.first
      colors = product.colors_sort_by_pictures
      articles = []
      diff_color = false
      if !op[:color].blank?
        articles = product.arts_for_color(true, op[:color].id) # Find the color from outfit
        diff_color = true if articles.empty?
      end
      if articles.empty? && !colors.empty?
        colors.each do |c|
          articles = product.arts_for_color(true, c.id)  # Find first available color to keep the color order
          break if articles.length > 0
        end
      end

      article = articles.sort_by {|a| a.size.order_index }.first
      if article.nil? # No available articles
        article = product.articles[0]
      end

      cd = @cart.cart_details.build(article: article, qty: op[:qty])
      cd.article.product = product # Use cache
      if diff_color
        cd.errors.add(:outfit_product_different_color, "Продуктът не е наличен в цвета от визията. Може да го закупите в друг цвят, или да го изтриете с бутона в дясно.")
      end
    end
  end

  def insert_to_cart
    @cart = Cart.new(cart_params)
    outfit_id = params[:cart][:outfit_id]
    @outfit = Outfit.find_by_id(outfit_id)

    added_product_ids = []
    prev_total = current_cart.total_with_discount
    success = true, error_message = ''
    rollback = false
    ActiveRecord::Base.transaction do
      @cart.cart_details.each do |d|
        begin
          success, error_message = add_detail_to_cart(d)
          added_product_ids << d.article.product_id
        rescue ActiveRecord::ActiveRecordError
          success = false
          error_message = 'Грешка в базата данни.'
        end
        if !success
          d.errors.add(:add_to_cart_error, error_message)
          rollback = true
        end
      end
      if rollback
        success = false
        raise ActiveRecord::Rollback
      end
    end
    if success
      flash[:products_added_to_cart] = {:ids => added_product_ids, :value => current_cart.total_with_discount - prev_total}
      redirect_to cart_show_path, notice: 'Продуктите от визията бяха добавени към количката Ви. Може да направите поръчка с бутона Започни поръчка в долния десен ъгъл'
    else
      render :add_to_cart
    end
  end

  def picture_present
    outfit = Outfit.find_by_id(params[:id])
    render json: { status: outfit.present? && outfit.picture.present? }
  end

  def pictures_for_product
    product_id = params[:product_id]
    product = Product.includes(:articles, :colors, product_pictures: [:color]).find_by_id(product_id)
    if product.blank?
      render json: { status: false }
      return
    end
    product_pictures = []
    product.product_pictures.each do |pp|
      product_pictures <<  {
        :id => pp.id,
        :product_id => pp.product_id,
        :product_name => product.name,
        :color_id => pp.color_id || product.single_color.try(:id) || 0,
        :color_name => pp.color.try(:name) || product.single_color.try(:name) || "",
        :min_price => product.min_price(false, pp.color_id),
        :max_price => product.max_price(false, pp.color_id),
        :outfit_compatible => pp.outfit_compatible,
        :image_url =>  {
          :thumb => pp.picture.url(:thumb),
          :original => pp.picture.url(:original)
        }
      }
    end
    render json: product_pictures
  end

  def load_more_products
    @products = search_products(Conf.search.initial_item_count, product_override_params)
    render json: [@products.map(&:html_safe)]
  end

  protected

  def product_override_params
    p = {}
    if user_signed_in? && current_user.merchant?
      p[:current_merchant_id] = current_user.merchant.id
    end
    p
  end

  def expand_category?(category, selected_category)
    if selected_category.outfit_category.nil?
      return category.occasion.nil?
    elsif selected_category.occasion.nil?
      return category.occasion.nil? && category.outfit_category == selected_category.outfit_category
    else
       return (category.occasion.nil? && category.outfit_category == selected_category.outfit_category) ||
              category.occasion == selected_category.occasion
    end
  end

  def category_path(category)
    if category.outfit_category.present? && category.outfit_category.key == "men"
      "#"
    else
      outfits_path(:category => category.outfit_category, :occasion => category.occasion)
    end
  end

  def category_text(category)
    category.occasion.nil? ? category.outfit_category.name : category.occasion.name
  end

  def has_children?(category)
    category.occasion.nil?
  end

  def category_children(category)
    outfit_sets = OutfitSet.includes(:occasion, :outfit_category).where("outfit_category_id = ? and occasion_id is not null", category.outfit_category_id)
    outfit_sets.sort_by { |os| os.occasion.order_index }
  end

  private

  def sections
    [:outfits, :my_outfits]
  end

  def outfit_params
    pars = params.require(:outfit).permit(:name,
    :serialized_json,
    :outfit_category_id,
    :image_filter,
    occasion_ids: [],
    outfit_product_pictures_attributes:
    [
      :id, :product_picture_id, :instances_count
    ])
    params.require(:template_row_index);
    template_ind = params[:template_row_index];
    # Deletes the fake template row
    pars[:outfit_product_pictures_attributes].delete(template_ind);
    # Remove pictures without instances
    pars[:outfit_product_pictures_attributes].each_value do |val|
      if val[:instances_count].to_i <= 0
        val[:_destroy] = true
      end
    end
    pars[:profile_id] = current_profile.id
    return pars
  end

  def cart_params
    pars = params.require(:cart).permit(
    cart_details_attributes:
    [
      :qty,
      article_attributes: [:product_id, :color_id, :size_id]
    ])
  end

  def add_detail_to_cart(cart_detail)
    qty = cart_detail.qty
    return true if qty < Conf.math.QTY_EPSILON
    product = Product.visible.find_by_id(cart_detail.article.product_id);
    if product.nil?
      return false, 'Продуктът вече не е активен и не може да бъде поръчан.'
    end
    if product.not_active?
      return false, 'Продуктът не е пуснат в продажба.'
    end
    size_id = cart_detail.article.size_id || 0
    color_id = cart_detail.article.color_id || 0
    if size_id <= 0 || color_id <= 0
      return false, 'Моля изберете цвят и размер.'
    end
    article = product.articles.where(color_id: color_id, size_id: size_id).take
    if article.nil?
      return false, 'Артикулът вече не съществува.'
    end

    begin
      current_cart.add_article(article, qty)
      return true
    rescue StandardError => e
      return false, e.message
    end
  end

  def save_svg_to_png_picture(scrape)
    svg = params.require(:serialized_svg)
    Modules::DelayedJobs::SvgSerializer.do(@outfit.id, request.base_url, svg, scrape)
  end

  def init_template_row
    # Insert the fake template row for easy new records insert
    @outfit.outfit_product_pictures.build(:id => -1)
  end

  def add_category_breadcrumb(category)
    add_breadcrumb "Визии #{category.name}", outfits_path(:category => category)
  end

  def load_outfit
    @outfit = Outfit.find_by_id(params[:id])
    if @outfit && !@outfit.is_visible_separately?
      redirect_not_visible_outfit(@outfit)
    end
    check_outfit
  end

  def load_profile_outfits
    @outfit = Outfit.includes(outfit_product_pictures: [product_picture: [product: [:colors]]]).where(profile_id: current_profile.id, id: params[:id]).first
    check_outfit
  end

  def check_outfit
    if @outfit.nil?
      redirect_to root_path, notice: "Визията не е намерена."
    end
  end

  def load_products
    @products = search_products(Conf.search.initial_item_count, product_override_params)
  end

  def categories_for_menu(category)
    outfit_sets = OutfitSet.includes(:outfit_category).where("outfit_category_id is not null and occasion_id is null")
    outfit_sets.sort_by { |os| os.outfit_category.order_index }
  end

  def redirect_category
    redirect_to outfits_path, :status => 301, :alert => "Категорията визии, която търсите, не бе намерена."
  end

  def try_redirect_product(product)
    if product.nil? || !product.is_visible?
      redirect_to outfits_path, :status => 301, :alert => "Продуктът, който търсите, не бе намерен."
      return true
    end
    if remove_marketing_params(request.fullpath) != product_outfits_path(product)
      redirect_to product_outfits_path(product), :status => 301
      return true
    end
    return false
  end

  def redirect_occasion(category)
    not_found_msg = "Категорията визии, която търсите, не бе намерена."
    if category.nil?
      redirect_to outfits_path, :status => 301, :alert => not_found_msg
    else
      redirect_to outfits_path(:category => category), :status => 301, :alert => not_found_msg
    end
  end

  def try_redirect_outfit(outfit, category)
    not_found_msg = "Визията, която търсите, не бе намерена."
    if outfit.nil?
      if category.nil?
        redirect_to outfits_path, :status => 301, :alert => not_found_msg
      else
        redirect_to outfits_path(:category => category), :status => 301, :alert => not_found_msg
      end
      return true
    elsif !outfit.is_visible_separately?
      redirect_not_visible_outfit(outfit)
      return true
    end
    if remove_marketing_params(request.fullpath) != outfit_path(outfit)
      redirect_to outfit_path(outfit), :status => 301
      return true
    end
    return false
  end

  def redirect_not_visible_outfit(outfit)
    redirect_to outfits_path(:category => outfit.outfit_category, :occasion => outfit.occasions.first), :status => 301, :alert => "Визията, която търсите, не бе намерена."
  end

end

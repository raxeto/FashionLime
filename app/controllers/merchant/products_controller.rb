class Merchant::ProductsController < MerchantController

  append_before_filter :load_product, only: [:edit, :update, :edit_pictures, :delete_picture, :add_picture, :update_picture_details, :destroy, :destroy_article_quantity]
  append_before_filter :load_product_articles, only: [:edit_articles, :update_articles]
  append_before_filter :load_product_quantities, only: [:edit_article_quantities, :update_article_quantities]
  append_before_filter :check_product_exists, except: [:index, :new, :create, :size_categories_for_product_category]

  helper_method :articles_collection

  add_breadcrumb "Моите продукти", :merchant_products_path
  add_breadcrumb "Нов продукт", :merchant_products_path, only: [:new]
  add_breadcrumb "Промяна на продукт", :merchant_products_path, except: [:index,
    :new, :create, :destroy]

  def index
    @products = current_merchant.products.order("created_at desc").includes(:trade_mark, :product_collection, :articles).all
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def edit_articles
  end

  def edit_article_quantities
    @new_art_qty = ArticleQuantity.new
    init_quantity_template_row()
  end

  def update
    if update_product(product_params)
      redirect_to edit_merchant_product_path(@product), notice: "Успешно редактиране."
    else
      render :edit
    end
  end

  def update_articles
    if update_product(product_articles_params)
      redirect_to edit_articles_merchant_product_path(@product), notice: "Успешно редактиране."
    else
      render action: :edit_articles
    end
  end

  def delete_picture
    begin
      @product.product_pictures.destroy(params.require(:picture_id))
      render json: { status: true }
    rescue ActiveRecord::RecordNotDestroyed
      render json: { status: false, error: 'Снимката не беше изтрита, защото се използва от други обекти от системата.'}
    end
  end

  def add_picture
    pars = params.permit(:color_id, :order_index)
    pars[:product_id] = @product.id
    pars[:picture] = params[:file_data]

    new_pic = ProductPicture.create(pars)
    if new_pic.persisted?
      render json: { status: true }
    else
      error_message = new_pic.errors.full_messages.join(", ")
      flash[:alert] = error_message
      render json: { status: false,  error: error_message }
    end
  end

  def update_picture_details
    pars = {}
    params.each do |k, v|
      if k.start_with?("picture_id") || k.start_with?("color_id") || k.start_with?("order_index")
        start_index = k.rindex('_') + 1
        ind = k[start_index..-1]
        if (!pars.has_key? ind) && (params["picture_id_#{ind}"].to_i != 0)
          pars[ind] = {
            # TODO escape with something (permit) params
            id: params["picture_id_#{ind}"],
            color_id: params["color_id_#{ind}"],
            outfit_compatible: 0,
            order_index: params["order_index_#{ind}"]
          }
        end
      end
    end

    if update_product({ product_pictures_attributes: pars.values })
      redirect_to edit_pictures_merchant_product_path, notice: "Успешно редактиране."
    else
      error_msg = @product.product_pictures.map {|p| p.errors.full_messages}.flatten.uniq.join(', ')
      redirect_to edit_pictures_merchant_product_path, alert: error_msg
    end
  end

  def update_article_quantities
    if update_product(product_art_quantities_params)
      redirect_to edit_article_quantities_merchant_product_path(@product), notice: "Успешно редактиране."
    else
      @new_art_qty = ArticleQuantity.new
      init_quantity_template_row()
      render :edit_article_quantities
    end
  end

  def destroy_article_quantity
    pars = params.permit(:article_quantity_id)
    begin
      quantity = @product.article_quantities.find(pars[:article_quantity_id])
      if quantity
        quantity.destroy!()
      end
      render json: { status: true }
    rescue ActiveRecord::RecordNotDestroyed
      render json: { status: false, error: quantity.errors[:qty].join(', ') }
    end
  end

  def create
    @product = current_merchant.products.create(product_params)
    unless @product.persisted?
      render :new
      return
    end
    redirect_to edit_merchant_product_path(@product), notice: 'Продуктът беше създаден.'
  end

  def destroy
    begin
      @product.destroy!()
      flash[:notice] = 'Продуктът беше изтрит.'
      render json: { status: true }
    rescue ActiveRecord::RecordNotDestroyed
      error = 'Продуктът не беше изтрит, защото се използва от други обекти от системата. Ако искате потребителите да не го виждат, можете да смените статуса му на "Скрит".'
    rescue ActiveRecord::ActiveRecordError
      error = 'Възникна грешка при изтриването на продукта.'
    end
    unless error.nil?
      flash[:alert] = error
      render json: { status: false, error: error }
    end
  end

  def size_categories_for_product_category
    categories = SizeCategory.includes(:sizes).for_product_category(params[:product_category_id]).order(:order_index)
    render json: {
      status: true,
      categories: categories.map { |c| {:name => c.name, :sizes => c.sizes.map { |s| {:id => s.id, :name => s.name}}} }.to_json
    }
  end

  def articles_collection
    Article.includes(:product, :color, :size).where(:product_id => params[:id]).order("colors.name, sizes.order_index").map { |a| [a.full_name, a.id] }
  end

private

  def update_product(parameters)
    has_error = false
    error_message = ''
    begin
      has_error = !@product.update_attributes(parameters)
    rescue ActiveRecord::StaleObjectError
      has_error = true
      error_message = "Възникна конфликт с друг потребител при промяна на продукта. Моля, опитайте отново."
    rescue StandardError => e
      has_error = true
      error_message = e.message
    end
    unless error_message.blank?
      flash.now[:alert] = error_message
    end
    return !has_error
  end

  def product_params
    pars = params.require(:product).permit(:trade_mark_id,
      :name,
      :description,
      :product_collection_id,
      :product_category_id,
      :status,
      :base_price,
      :min_available_qty,
      size_ids: [],
      color_ids: [],
      occasion_ids: [])

    pars[:user_id] = current_user.id

    return pars
  end

  def product_articles_params
     params.require(:product).permit(:id,
      articles_attributes: [:id, :price, :perc_discount, :price_with_discount, :sku])
  end

  def product_art_quantities_params
    allowed = params.require(:product).permit(:id,
      articles_attributes: [:id,
        article_quantities_attributes: [:id, :article_id, :qty, :part, :note, :active, :_destroy]])

    params[:product][:articles_attributes].each do |ak, av|
      av[:article_quantities_attributes].each do |k, v|
        if v.has_key?(:id) && v[:id].to_i == -1
          allowed[:articles_attributes][ak][:article_quantities_attributes].delete(k);
        end
      end

      if allowed[:articles_attributes][ak].empty?
        allowed[:articles_attributes].delete(ak)
      end
    end

    return allowed
  end

  def product_pictures_params
    pars = params.require(:product).permit(
      product_pictures_attributes: [:id, :color_id, :picture, :outfit_compatible, :order_index] )

    pars[:user_id] = current_user.id

    return pars
  end

 def init_quantity_template_row
    # Insert the fake template row for easy new records insert
    @product.articles.each do |a|
      a.article_quantities.build(:id => -1)
    end
  end

  def load_product
    @product = current_merchant.products.find_by_id(params[:id])
  end

  def load_product_articles
    @product = current_merchant.products.includes(articles: [:size, :color]).where(:id => params[:id]).first
  end

  def load_product_quantities
    @product = current_merchant.products.includes(articles: [article_quantities: [article: [:product, :size, :color]]]).where(:id => params[:id]).first
  end

  def check_product_exists
    if !@product
      redirect_to merchant_products_path, alert: 'Този продукт не принадлежи на Вашия акаунт и не можете да го манипулирате!'
    end
  end

  def sections
    [:products]
  end

end

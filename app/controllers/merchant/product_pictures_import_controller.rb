class Merchant::ProductPicturesImportController < MerchantController

  add_breadcrumb "Моите продукти", :merchant_products_path
  add_breadcrumb "Импорт на снимки", :merchant_new_product_pictures_import_path

  def new
    @products = current_merchant.products.order(:name)
  end

  def product_info
    product = current_merchant.products.find_by_id(params[:product_id])

    if product.present?
      render json: {
        :preview_id => params[:preview_id],
        :colors => product.colors.order(:order_index).map { |c| { :id => c.id, :name => c.name } },
        :color_required => product.color_ids.size > 1
      }
    else
      render json: {
        :preview_id => params[:preview_id],
        :not_found => true
      }
    end

  end

  def create
    pars = params.permit(:product_id, :color_id, :order_index)
    pars[:picture] = params[:file_data]

    if !current_merchant.products.where(:id => pars[:product_id]).exists?
      render json: { status: false,  error: 'ненамерен продукт' }
      return
    end

    new_pic = ProductPicture.create(pars)
    if new_pic.persisted?
      render json: { status: true }
    else
      error_message = new_pic.errors.full_messages.join(", ")
      render json: { status: false,  error: error_message }
    end
  end

  protected


  def sections
    [:products]
  end

end

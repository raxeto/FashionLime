class Admin::StaleOrdersController < AdminController

  helper_method :product_path

public

  def index
    @orders = MerchantOrder.includes(:merchant, :order).order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def index_returns
    @returns = MerchantOrderReturn.includes({ merchant_order: [:order, :merchant] }, :merchant_order_return_details, :user).order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def show_return
    @return = MerchantOrderReturn.includes(:merchant_order, :merchant_order_return_details, :user).find(params[:id])
  end

  def show_order
    @merchant_order = MerchantOrder.includes(:merchant, :order, :payment_type).find(params[:id])
    @order = @merchant_order.order
    @return = @merchant_order.merchant_order_return
  end

  def confirm_order
    @merchant_order = MerchantOrder.includes(:merchant, :order, :payment_type).find(params[:id])
    @merchant_order.skip_email_on_status_change = true
    if @merchant_order.update_attributes(status: 3)
      redirect_to admin_stale_order_path(@merchant_order), notice: 'Поръчката беше потвърдена успешно'
    else
      redirect_to admin_stale_order_path(@merchant_order), alert: 'Възникна грешка в потвърждението!'
    end
  end

protected
  def product_path(product)
    product_or_subcategory_path(product_url_params(product))
  end

  def product_url_params(product)
    {
      :category => Modules::ProductCategoryCache.master_category_url(product.product_category_id),
      :subcategory_or_product => product.to_client_param
    }
  end
end

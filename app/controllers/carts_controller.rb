class CartsController < ClientController

  append_before_filter :load_current_user_cart

  add_breadcrumb "Количка", :cart_show_path

  def show
    @cart_details = @cart.cart_details.includes(:article => [:color, :size, product: [:merchant, product_pictures: [:color, product: [:merchant, :occasions]] ] ]).order("articles.name")
  end

  def update_cart_details
    pars = params.require(:cart).permit(cart_details_attributes: [:id, :qty])

    error_msg = nil
    begin
      @cart.update_detail(pars[:cart_details_attributes][:id], pars[:cart_details_attributes][:qty].to_d)
    rescue StandardError => e
      error_msg = e.message
    end

    if error_msg.nil?
      cart_detail = CartDetail.find(pars[:cart_details_attributes][:id])
      render json: { status: true, new_total: cart_detail.total_with_discount }
    else
      render json: { status: false, error: error_msg }
    end
  end

  def destroy_item
    pars = params.require(:cart).permit(cart_details_attributes: [:id])
    @cart.cart_details.find(pars[:cart_details_attributes][:id]).destroy()
    render json: { status: true }
  end

  protected

  def sections
    [:cart]
  end

  def load_current_user_cart
    @cart = current_cart
  end

end

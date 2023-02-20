class OrdersController < ClientController

  append_before_filter :load_user, only: [:new, :create, :new_return, :create_return, :additional_payment_step, :thank_you]
  append_before_filter :load_cart, only: [:new]
  append_before_filter :load_signed_in_user, only: [:index, :show]
  append_before_filter :load_merchant_order, only: [:show, :thank_you]
  append_before_filter :load_return_code_and_email, only: [:new_return, :create_return]
  append_before_filter :load_user_addresses, only: [:new, :create]

  add_breadcrumb "Поръчки", :orders_path
  add_breadcrumb "Нова поръчка", :new_order_path, only: [:new]
  add_breadcrumb "Връщане или замяна", :new_return_order_path, only: [:new_return, :create_return]

  def index
    @merchant_orders = @user.merchant_orders.includes(:merchant, :merchant_order_details, :merchant_order_return).order(created_at: :desc)
  end

  def show
    add_breadcrumb "Детайли на поръчка", order_path(:number => @merchant_order.number)
  end

  def new
    # Stop new orders for now
    redirect_to root_path, alert: 'Възникна грешка при обработката на заявката Ви.'

    item_count = @cart.item_count
    if item_count > Conf.order.max_items
      Rails.logger.error("User #{@user.username} has requested #{item_count.to_i} items from IP:#{request.remote_ip}")
      redirect_to cart_show_path, alert: I18n.t('controllers.orders.cart_too_big', count: Conf.order.max_items)
    else
      @order = @user.orders.build({:user_email => @user.email,
                                 :user_phone => @user.phone,
                                 :user_first_name => @user.first_name,
                                 :user_last_name => @user.last_name,
                                 :agree_terms_of_use => true })

      @has_profile_copied_info = !@user.email.blank? || !@user.phone.blank? || !@user.first_name.blank? || !@user.last_name.blank?
      @order.build_address()

      init_merchant_orders()
    end
  end

  def create
    @order = @user.orders.build(order_params)
    has_error = false
    error_message = ''
    begin
      has_error = !@order.save
    rescue StandardError => e
      has_error = true
      error_message = e.message
    end

    if has_error
      unless error_message.blank?
        flash.now[:alert] = error_message
      end
      @has_user_error = true
      render :new
      return
    end

    if !@order.set_payment_codes
      Rails.logger.error("Setting payment codes for order with ID #{@order.id} unsuccessful.")
    end

    Modules::DelayedJobs::OrderEmailSender.send(@order.id)

    cart_cleared = current_cart.make_empty_after_order
    if @order.has_additional_payment?
      redirect_to show_additional_payment_step_path(:first_order_number => @order.merchant_orders.first.number)
      return
    end

    if !cart_cleared
      Rails.logger.error("Failed to empty cart ID #{current_cart.id}")
    end

    redirect_to thank_you_path(:number => @order.merchant_orders.first.number)
  end

  def thank_you
    @order = @merchant_order.order
  end

  def additional_payment_step
    merchant_order = MerchantOrder.includes(order: [merchant_orders: [:merchant, :merchant_order_details, merchant_payment_type: [:payment_type, :info]]]).find_by_number(params.require(:first_order_number))
    order = merchant_order.present? ? merchant_order.order : nil
    if order.blank? || order.user.id != current_or_guest_user.id
      redirect_to root_path, alert: 'Невалиден номер на поръчка.'
      return
    end
    @merchant_orders = order.merchant_orders.select { |mo| mo.merchant_payment_type.payment_type.requires_action }
    add_breadcrumb "Информация за плащане", show_additional_payment_step_path(:first_order_number => merchant_order.number)
  end

  def get_epay_code
    merchant_order = MerchantOrder.find_by_number(params.require(:order_number))
    @order = merchant_order.present? ? merchant_order.order : nil
    if @order.blank? || @order.user.id != current_or_guest_user.id
      render json: { status: false, error_code: "not_found", payment_code: nil }
    elsif merchant_order.payment_code == Conf.payments.epay_failed_code
      render json: { status: false, error_code: "epay_error", payment_code: nil }
    else
      render json: { status: true, payment_code: merchant_order.payment_code }
    end
  end

  def new_return
    if @return_code.blank? || @confirm_email.blank?
      @order_return = nil
      # Only one of them is filled in
      if !@return_code.blank? || !@confirm_email.blank?
        flash.now[:alert] = "Непълен линк за връщане или замяна."
      end
    else
      merchant_order, error_code, error_message = get_order_to_return(@return_code, @confirm_email)
      if merchant_order.nil?
        if error_code == :wrong_input
          flash.now[:alert] = error_message
        else
          redirect_to root_path, alert: error_message
        end
        return
      end
      merchant_order = MerchantOrder.includes(:merchant, merchant_order_details: [article: [:size, :color, product: [product_pictures: [:color, product: [:merchant, :occasions]]]]]).find_by_id(merchant_order.id)
      @order_return = MerchantOrderReturn.new_from_order(merchant_order)
    end
  end

  def create_return
    @order_return = @user.merchant_order_returns.build(return_params)
    merchant_order, error_code, error_message = get_order_to_return(@return_code, @confirm_email)
    if merchant_order.nil? || merchant_order.id != (@order_return.merchant_order.try(:id) || 0)
      redirect_to root_path, alert: error_message
      return
    end
    if @order_return.merchant_order_return_details.select{ |d| d.return_qty <= Conf.math.QTY_EPSILON}.length == @order_return.merchant_order_return_details.length
      flash.now[:alert] = 'Няма избрани продукти за връщане или замяна.'
      render :new_return
      return
    end
    @order_return.merchant_order_return_details.each do |d|
      @order_return.merchant_order_return_details.delete(d) if d.return_qty <= Conf.math.QTY_EPSILON
    end
    unless @order_return.save
      if @order_return.errors[:merchant_order_mismatch_detail].present? || @order_return.errors[:merchant_order_id].present?
        redirect_to root_path, alert: @order_return.errors[:merchant_order_mismatch_detail].join(', ') +  ' ' + @order_return.errors[:merchant_order_id].join(', ')
        return
      end
      render :new_return
      return
    end

    OrderMailer.merchant_return(@order_return).deliver_now
    OrderMailer.user_return(@order_return).deliver_now
    redirect_to root_path, notice: 'Заявката за връщане/замяна беше успешно направена.'
  end

  private

  def sections
    [:my_menu, :my_orders]
  end

  def order_params
    params.require(:order).permit(
      :user_email,
      :user_phone,
      :user_first_name,
      :user_last_name,
      :user_address_id,
      :note_to_merchants,
      :only_business_days,
      :issue_invoice,
      :agree_terms_of_use,
      address_attributes: [:location_id, :location_suggestion, :description],
      merchant_orders_attributes:[:merchant_id, :merchant_shipment_id, :merchant_payment_type_id, :shipment_price,
      merchant_order_details_attributes: [:article_id, :price, :perc_discount, :price_with_discount, :total_with_discount, :qty]])
  end

  def return_params
    pars = params.require(:merchant_order_return).permit(
      :merchant_order_number,
      :user_first_name,
      :user_last_name,
      :user_email,
      :user_phone,
      :note_to_merchant,
      merchant_order_return_details_attributes:
      [
        :article_id, :return_qty, :return_type
      ]
    )
    # Set merchant order id from nubmer
    merchant_order = MerchantOrder.includes(:merchant_order_details).find_by_number(pars[:merchant_order_number])
    pars[:merchant_order_id] = merchant_order.try(:id)
    pars.delete(:merchant_order_number)
    pars[:merchant_order_return_details_attributes].each do |k, v|
      if merchant_order.present?
        v[:merchant_order_detail_id] = merchant_order.merchant_order_details.select { |d| d.article_id == v[:article_id].to_i }.first.try(:id)
      end
      v.delete(:article_id)
    end
    pars
  end


  def init_merchant_orders
    details = @cart.cart_details.includes(article: [
      :size, :color, product: [
        product_pictures: [
          :color, product: [
            :merchant, :occasions
          ]
        ],
        merchant: [
          :payment_types, :available_shipments, :available_merchant_payment_types
        ]
      ]
    ])

    details = details.sort_by { |d| [d.article.product.merchant.name, d.article.product.merchant_id, d.article.product.name] }

    merchant_order = nil
    details.each do |d|
      merchant_id = d.article.product.merchant_id
      if merchant_order.nil? || merchant_order.merchant_id != merchant_id
        merchant_order = @order.merchant_orders.build(merchant: d.article.product.merchant)
      end

      if d.article.product.is_visible? && !d.article.product.not_active?
        merchant_order_detail = merchant_order.merchant_order_details.build(
            article: d.article,
            price: d.price,
            perc_discount: d.perc_discount,
            price_with_discount: d.price_with_discount,
            qty: d.qty)

        if merchant_order_detail.is_price_changed?
          merchant_order_detail.reset_price()
           @cart_prices_are_changed = true
        end

        merchant_order_detail.calc_totals()
      end
    end

    @order.merchant_orders.each do |mo|
      if mo.merchant_order_details.size == 0
        @order.merchant_orders.delete(mo)
      else
        # Set initial shipment
        mo.merchant.available_shipments.each do |s|
          if s.min_order_price <= mo.total_with_discount
            mo.merchant_shipment = s
            mo.shipment_price = mo.merchant_shipment.price
            break
          end
        end

        # Set initial payment
        if mo.merchant_shipment.present? && mo.merchant_shipment.payment_type.present?
          mo.merchant_payment_type = mo.merchant.available_merchant_payment_types.select { |p| p.payment_type_id == mo.merchant_shipment.payment_type_id }.first
        elsif mo.merchant.available_merchant_payment_types.size > 0
          mo.merchant_payment_type = mo.merchant.available_merchant_payment_types.first
        end
      end
    end
  end

  def get_order_to_return(return_code, email)
    # replace whitespaces
    if return_code.blank? || email.blank?
      merchant_order = nil
    else
      return_code = return_code.gsub(/\s+/, "")
      merchant_order = MerchantOrder.find_by_return_code(return_code)
    end
    error_code = nil
    error_message = ''
    if merchant_order.nil?
      error_code = :not_found
      error_message = 'Поръчката не може да бъде намерена.'
    else
      if !merchant_order.merchant_order_return.nil?
        error_code = :already_generated
        error_message = "Вече е генерирана заявка за връщане и замяна за тази поръчка."
      elsif merchant_order.return_attempts >= Conf.order.return_max_attempts
        error_code = :too_many_attempts
        error_message = 'Поръчката е заключена за връщане заради твърде много неуспешни опити. Свържете се с екипа на FashionLime.'
      elsif merchant_order.return_deadline_passed?
        error_code = :return_deadline_passed
        error_message = 'Изтекъл е крайният срок за връщане на тази поръчка.'
      elsif merchant_order.order.user_email != email
        error_code = :wrong_input
        error_message = 'Невалидни данни за връщане на поръчка.'
        merchant_order.update_attributes(:return_attempts => merchant_order.return_attempts + 1)
      end
    end

    unless error_code.nil?
      return nil, error_code, error_message
    end
    return merchant_order
  end

  def load_user
    @user = current_or_guest_user
  end

  def load_merchant_order
    @merchant_order = @user.merchant_orders.includes(:merchant, merchant_order_details: [article: [:size, :color, product: [product_pictures: [:color, product: [:merchant, :occasions]]]]]).find_by_number(params[:number])
    if @merchant_order.nil?
      redirect_to orders_path, alert: "Поръчката не бе намерена."
    end
  end

  def load_signed_in_user
    if user_signed_in?
      @user = current_user
    else
      flash[:warning] = "За да виждате поръчките си трябва да сте регистриран в системата. Влезте, ако имате регистрация, или се регистрирайте сега, за да виждате бъдещите си поръчки и за да достъпвате всички интересни функционалности, които FashionLime предлага!"
      redirect_to new_user_registration_path
    end
  end

  def load_cart
    @cart = current_cart
    if @cart.cart_details.empty?
      redirect_to root_path, alert: 'Количката Ви е празна и не можете да направите поръчка.'
    end
  end

  def load_return_code_and_email
    @return_code = params[:return_code]
    @confirm_email = params[:confirm_email]
  end

  def load_user_addresses
    @user_addresses = @user.addresses.joins(:location).
      includes(location: [:location_type, parent: [:location_type]]).
      where("locations.location_type_id != ?", LocationType.find_by_key('user_suggested').id).
      order(id: :desc)
  end

end

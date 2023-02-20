class Merchant::OrdersController < MerchantController

  append_before_filter :add_orders_breadcrumb

  append_before_filter :load_merchant
  append_before_filter :load_merchant_order,   only: [:update, :edit]
  append_before_filter :load_merchant_return,  only: [:update, :edit]

  def index
    @status_filter = params[:status]
    where_clause = {}
    if @status_filter.present?
      where_clause[:status] = @status_filter.map { |s| MerchantOrder.statuses[s] }
    else
      @status_filter = []
    end
    order_models = @merchant.merchant_orders.includes(:merchant_order_details, :merchant_order_return, :payment_type, order:[:user, address:[:location]], merchant_shipment: [:shipment_type, :payment_type]).
              where(where_clause).
              order(@status_filter.include?("active") ? "aprox_delivery_date_to, created_at" : "created_at desc")
    @orders = order_models.map {
      |o| {
        :number => o.number,
        :created_at => date_time_to_s(o.created_at),
        :user_full_name => o.order.user_full_name,
        :location_name => o.order.address.location.name,
        :only_business_days => o.order.only_business_days == 1 ? 'ДА' : 'НЕ',
        :issue_invoice => o.order.issue_invoice == 1 ? 'ДА' : 'НЕ',
        :merchant_shipment_name => o.merchant_shipment.name,
        :merchant_payment_type_name => o.payment_type.name,
        :payment_code => o.payment_code_human_readable,
        :total_with_shipment => o.total_with_shipment_formatted_without_unit,
        :has_return => o.merchant_order_return.present? ? 'ДА' : 'НЕ',
        :aprox_delivery => o.aprox_delivery,
        :note_to_merchants => truncate_string(o.order.note_to_merchants, 30),
        :acknowledged_date => date_to_s(o.acknowledged_date),
        :status => o.status_i18n
      }.to_json
    }
  end

  def edit
  end

  def update
    if @merchant_order.update_attributes(order_params)
      redirect_to merchant_edit_order_path(:number => @merchant_order.number), notice: "Успешно редактиране."
    else
      render :edit
    end
  end

  private

  def order_params
    params.require(:merchant_order).permit(:id,
      :merchant_shipment_id, :shipment_price,
      :acknowledged_date, :note_to_user, :status, :cancellation_note)
  end

  def add_orders_breadcrumb
    add_breadcrumb "Поръчки", merchant_orders_path(:status => ['active', 'waiting_payment'])
  end

  def load_merchant
    @merchant = current_merchant
  end

  def load_merchant_order
    @merchant_order = MerchantOrder.includes(merchant_payment_type: [:payment_type, :info], merchant_order_details: [:article_quantities, article: [:product, :color, :size]],
      order:[:user, address:[:location]], merchant_shipment: [:shipment_type, :payment_type]).find_by_number(params[:number])
    if @merchant_order.nil? || @merchant_order.merchant_id != current_merchant.id
      redirect_to merchant_orders_path(:status => ["active", "waiting_payment"])
      return
    end
    add_breadcrumb "Промяна на поръчка", merchant_edit_order_path(:number => @merchant_order.number)
  end

  def load_merchant_return
    @order_return = MerchantOrderReturn.find_by :merchant_order_id => @merchant_order.id
  end

  def sections
    [:orders]
  end

end

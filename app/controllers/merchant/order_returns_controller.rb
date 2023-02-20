class Merchant::OrderReturnsController < MerchantController

  append_before_filter :load_merchant
  append_before_filter :load_merchant_order_return, only: [:show, :process_returns, :process_exchanges, :mark_returned]
  append_before_filter :load_merchant_order_return_details, only: [:show]

  append_before_filter :add_order_returns_breadcrumb

  def index
    @status_filter = params[:status]
    where_clause = {}
    if @status_filter.present?
      where_clause[:status] = MerchantOrderReturn.statuses[@status_filter]
    end
    where_clause[:merchant_orders] = { :merchant_id => @merchant.id }
    @order_returns = MerchantOrderReturn.joins(:merchant_order).includes(:user, :merchant_order).
      where(where_clause).
      order(created_at: :desc).map {
      |r| {
        :number => r.number,
        :created_at => date_time_to_s(r.created_at),
        :user_full_name => r.user_full_name,
        :order_number => r.merchant_order.number,
        :note_to_merchant => truncate_string(r.note_to_merchant, 50),
        :status => r.status_i18n
      }.to_json
    }
  end

  def show
    add_breadcrumb "Детайли заявка", merchant_order_return_path(:number => @order_return.number)
  end

  def process_returns
    if @order_return.process_returns
      redirect_to merchant_order_return_path(:number => @order_return.number), notice: "Връщанията бяха успешно обработени."
    else
      redirect_to merchant_order_return_path(:number => @order_return.number), alert: "Възникна грешка при обработката на връщанията."
    end
  end

  def process_exchanges
    new_articles = JSON.parse params[:new_articles]
    if @order_return.process_exchanges(new_articles)
      redirect_to merchant_order_return_path(:number => @order_return.number), notice: "Замените бяха успешно обработени."
    else
      redirect_to merchant_order_return_path(:number => @order_return.number), alert: "Възникна грешка при обработката на замените."
    end
  end

  def mark_returned
    return_type = params[:return_type]
    if @order_return.mark_details_as_returned(return_type)
      redirect_to merchant_order_return_path(:number => @order_return.number), notice: "Продуктите бяха маркирани като върнати."
    else
      redirect_to merchant_order_return_path(:number => @order_return.number), alert: "Възникна грешка при маркирането на продуктите като върнати."
    end
  end

  private

  def add_order_returns_breadcrumb
    # Can't pass parameter directly in the add_breadcrumb before filter
    add_breadcrumb "Заявки връщане", merchant_order_returns_path(:status => "active")
  end

  def load_merchant
    @merchant = current_merchant
  end

  def load_merchant_order_return
    merchant_order = MerchantOrder.find_by_return_code(params[:number])
    if merchant_order.present?
      @order_return = MerchantOrderReturn.includes(:merchant_order, :user, merchant_order_return_details: [merchant_order_detail: [article: [:product, :color, :size]]]).find_by_merchant_order_id(merchant_order.id)
    end
    if merchant_order.nil? || @order_return.nil? || @order_return.merchant_order.merchant_id != @merchant.id
      redirect_to merchant_order_returns_path(:status => "active")
    end
  end

  def load_merchant_order_return_details
    @return_details = @order_return.merchant_order_return_details.select {|o| o.return_type == "return"}
    @exchange_details = @order_return.merchant_order_return_details.select {|o| o.return_type == "exchange"}
  end

  def sections
    [:orders]
  end

end

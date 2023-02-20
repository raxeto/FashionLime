class InformationController < ClientController

  add_breadcrumb "Нов търговски профил", :information_new_merchant_path, only: [:new_merchant]
  add_breadcrumb "За нас", :about_us_path, only: [:about_us]
  add_breadcrumb "Плащане и доставка", :information_delivery_payment_path, only: [:delivery_and_payment ]

  def new_merchant
    render :layout => "no_container"
  end

  def about_us
    render :layout => "no_container"
  end

  def delivery_and_payment
    @payment_types  = PaymentType.all.order(:order_index)
    @shipment_types = ShipmentType.all.order(:order_index)
  end

  def coming_soon
    render :layout => false
  end

end

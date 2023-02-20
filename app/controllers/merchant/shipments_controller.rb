class Merchant::ShipmentsController < Merchant::ActivationStepController

  add_breadcrumb "Доставки", :merchant_shipments_path

  def index
    @merchant = Merchant.includes(:merchant_shipments).find_by(id: current_merchant_id)
    @new_shipment = MerchantShipment.new
    init_template_row()
  end

  def update_shipments
    @merchant = current_merchant
    @new_shipment = MerchantShipment.new

    @merchant.skip_validation = true
    result = @merchant.update_attributes(shipments_params)
    @merchant.skip_validation = false

    if result
      on_activation_step_complete()
      if is_in_activation?
        redirect_to_activation_next_step(activation_step, method(:merchant_shipments_path))
      else
        redirect_to merchant_shipments_path, notice: "Успешно редактиране."
      end
    else
      init_template_row()
      render :index
    end
  end

  def destroy_item
    @merchant = current_merchant
    pars = params.permit(:id)
     # Merchant shipment can not be deleted if there is merchant orders associated.
    begin
      @merchant.skip_validation = true
      shipment = @merchant.merchant_shipments.find(pars[:id])
      if shipment
        shipment.destroy!()
      end
      @merchant.skip_validation = false
      render json: { status: true }
    rescue ActiveRecord::RecordNotDestroyed
      result = false
      @merchant.skip_validation = false
      render json: { status: false, error: shipment.errors[:base].join(', ') }
    end
  end

  def activation_step
    return Conf.merchant_activation.shipments_step
  end

  def shipments_params
    pars = params.require(:merchant).permit(:id,
    merchant_shipments_attributes:
    [
      :id, :shipment_type_id, :payment_type_id,
      :name, :description,
      :period_from, :period_to, :period_type,
      :price, :min_order_price,
      :active
    ])

    params.require(:template_row_index);
    template_ind = params[:template_row_index];

    # Deletes the fake template row
    pars[:merchant_shipments_attributes].delete(template_ind);

    return pars
  end

  private

  def sections
    [:settings]
  end

  def init_template_row
    # Insert the fake template row for easy new records insert
    @merchant.merchant_shipments.build(:id => -1)
  end

end

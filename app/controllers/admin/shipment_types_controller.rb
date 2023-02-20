class Admin::ShipmentTypesController < AdminController

  def index
    @shipment_types = ShipmentType.all
  end

  def new
    @shipment_type = ShipmentType.new
  end

  def edit
    @shipment_type = ShipmentType.find(params[:id])
  end

  def update
    @shipment_type = ShipmentType.find(params[:id])
    
    unless @shipment_type.update_attributes(shipment_type_params)
      render :edit
      return
    end
    redirect_to admin_shipment_types_path, notice: 'Shipment type edited successfully.'
    end

  def create
    @shipment_type = ShipmentType.new(shipment_type_params)
    unless @shipment_type.save
      render :new
      return
    end
    redirect_to admin_shipment_types_path, notice: 'Shipment type created successfully!'
  end

  private

  def shipment_type_params
    params.require(:shipment_type).permit(:name, :description, :order_index, :picture)
  end


end

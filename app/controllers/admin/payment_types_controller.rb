class Admin::PaymentTypesController < AdminController

  def index
    @payment_types = PaymentType.all
  end

  def new
    @payment_type = PaymentType.new
  end

  def edit
    @payment_type = PaymentType.find(params[:id])
  end

  def update
    @payment_type = PaymentType.find(params[:id])
    
    unless @payment_type.update_attributes(payment_type_params)
      render :edit
      return
    end
    redirect_to admin_payment_types_path, notice: 'Payment type edited successfully.'
    end

  def create
    @payment_type = PaymentType.new(payment_type_params)
    unless @payment_type.save
      render :new
      return
    end
    redirect_to admin_payment_types_path, notice: 'Payment type created successfully!'
  end

  private

  def payment_type_params
    params.require(:payment_type).permit(:name, :description, :order_index, :picture)
  end


end

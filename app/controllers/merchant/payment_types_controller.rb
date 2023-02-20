class Merchant::PaymentTypesController < Merchant::ActivationStepController

  append_before_filter :check_activated, only: [:new_activation, :create_activation]
  append_before_filter :load_payment, only: [:edit, :update]

  add_breadcrumb "Начини на плащане", :merchant_payment_types_path
  add_breadcrumb "Нов начин на плащане", :new_merchant_payment_type_path,  only:  [:new, :create]
  add_breadcrumb "Промяна на начин на плащане", :edit_merchant_payment_type_path,  only: [:edit, :update]

  def index
    @payments = current_merchant.merchant_payment_types.order(created_at: :desc)
  end

  def new_activation
    @payments = []
    PaymentType.order(:order_index).each do |p|
      @payments << MerchantPaymentType.new(:payment_type => p)
    end
    render :activation
  end

  def create_activation
    pars = activation_payment_params
    @payments = []
    pars[:payment].each_value do |payment_params|
      payment = create_payment(payment_params)
      @payments << payment
    end
    
    error = false
    ActiveRecord::Base.transaction do
      @payments.each do |p|
        if p.active == 1
          if !p.save_payment
            error = true
          end
        end
      end
      if error
        raise ActiveRecord::Rollback
      end
    end

    if error
      render :activation
    else
      on_activation_step_complete()
      if is_in_activation?
        redirect_to_activation_next_step(activation_step, method(:merchant_payment_types_activation_path))
      else
        redirect_to merchant_shipments_path, notice: "Успешно редактиране."
      end
    end
  end

  def new
    if params[:payment_type].present?
      payment_type = PaymentType.find_by_id(params[:payment_type])
      @payment = MerchantPaymentType.new(:payment_type => payment_type)
    else
      @payment_types = PaymentType.order(:order_index)
    end
  end

  def create
    @payment = create_payment(payment_params)
    if save_payment(@payment)
      redirect_to merchant_payment_types_path, notice: "Успешно създаване на начин на плащане."
    else
      render :new
    end
  end

  def edit
  end

  def update
    pars = payment_params
    @payment.assign_attributes(pars.permit(:active))
    assign_info_attributes(@payment, pars)
    if save_payment(@payment)
      redirect_to merchant_payment_types_path, notice: "Успешно редактиране на начин на плащане."
    else
      render :edit
    end
  end

  def activation_step
    return Conf.merchant_activation.payments_step
  end

  private

  def activation_payment_params
    params.permit(
      payment: [
        :payment_type_id, :active,
        :company_name, :iban, :bic_code, :currency, :bank_name,
        :min_code, :secret
      ]
    )
  end

  def payment_params
    params.require(:merchant_payment_type).permit(
      :id, :payment_type_id, :active,
      :company_name, :iban, :bic_code, :currency, :bank_name,
      :min_code, :secret
    )
  end

  def create_payment(pars)
    merchant_id = current_merchant.id
    payment = MerchantPaymentType.new(pars.permit(:payment_type_id, :active).merge(:merchant_id => merchant_id))
    assign_info_attributes(payment, pars)
    payment
  end

  def assign_info_attributes(payment, pars)
    if payment.info.present?
      info_params = pars.except(:id, :payment_type_id, :active)
      # Exclude secret if it's blank bacause we don't set its original value in the input
      if info_params[:secret].blank?
        info_params = info_params.except(:secret)
      end
      payment.info.assign_attributes(info_params)
    end
  end

  def save_payment(payment)
    success = true
    ActiveRecord::Base.transaction do
      success = payment.save_payment
      if !success
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  def load_payment
    @payment = current_merchant.merchant_payment_types.find_by_id(params[:id])
    if @payment.nil?
      redirect_to merchant_payment_types_path, alert: "Начинът на плащане не беше намерен."
    end
  end

  def check_activated
    if activation_step_completed?(activation_step)
      redirect_to merchant_payment_types_path
    end
  end

  def sections
    [:settings]
  end

end

class Merchant::ActivationController < MerchantController
  include Modules::MerchantActivationLib

  append_before_filter :check_status

  def index
    redirect_to_first_activation_step
  end

  private

  def check_status
    if !current_merchant.not_completed?
      redirect_to merchant_root_path, notice: "Профилът Ви вече е активиран."
    end
  end
end

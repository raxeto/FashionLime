class Merchant::ActivationStepController < MerchantController

  include Modules::MerchantActivationLib

  helper_method :activation_step, :is_in_activation?, :step_description

  append_before_filter :load_activation
  
end

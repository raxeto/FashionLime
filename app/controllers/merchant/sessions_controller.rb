 class Merchant::SessionsController < Devise::SessionsController

  include Modules::MerchantLib
  include Modules::PasswordManagingController
  include Modules::ClientControllerLib

  append_before_filter :authenticate_as_merchant, only: [:destroy]
  add_breadcrumb "Влез", :merchant_sessions_new_path, only: [:new, :create]

  def new
    @sign_in_user = resource_class.new(sign_in_params)
    super
  end

  protected

  def after_sign_in_path_for(resource)
    merchant_root_path
  end

  def sections
    [:my_menu]
  end

end

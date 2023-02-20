 class SessionsController < Devise::SessionsController

  include Modules::MerchantLib
  include Modules::PasswordManagingController
  include Modules::ClientControllerLib

  append_before_filter :authenticate_as_non_guest, only: [:destroy]
  add_breadcrumb "Влез", :new_user_session_path, only: [:new, :create]

  def new
    @sign_in_user = resource_class.new(sign_in_params)
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.merchant?
      merchant_root_path
    elsif session["user_return_to"].present? && session["user_return_to"].start_with?(merchant_url_prefix)
      root_path
    else
      super(resource)
    end
  end

  def sections
    [:my_menu]
  end

end

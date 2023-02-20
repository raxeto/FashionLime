 class RegistrationsController < Devise::RegistrationsController

  include Modules::MerchantLib
  include Modules::DeviseHelpersLib
  include Modules::ClientControllerLib

  append_before_filter :authenticate_as_non_guest, only: [:edit, :update_profile]
  add_breadcrumb "Регистрирай се", :new_user_session_path, only: [:new, :create]
  add_breadcrumb "Промяна на профил", :edit_user_registration_path, only: [:edit, :update_profile]

  def deactivate
    current_user.not_active!
    reset_session
    redirect_to root_path
  end

  def edit
    @show_password_field = false
    current_user.email_o = current_user.email
    super
  end

  def update_profile
    update_user_profile(current_user)
  end

  protected

  def after_update_profile_path_for(user)
    root_path
  end

  def after_sign_up_path_for(resource)
    if session["user_return_to"].present? && session["user_return_to"].start_with?(merchant_url_prefix)
      root_path
    else
      super(resource)
    end
  end

  def sections
    [:my_menu, :edit_profile]
  end

  def sign_up_params
    extract_optional_email(super)
  end

  def account_update_params
    params = extract_optional_email(super)
    params[:current_password] = params[:current_password_o]
    params.delete(:current_password_o)
    return params
  end

  def extract_optional_email(params)
    if !current_or_guest_user.merchant?
      params[:email] = params[:email_o]
    end
    return params
  end

  def build_resource(hash=nil)
    super
    # Create an instance var to use just for the sign up form
    @sign_up_user = self.resource
  end

end

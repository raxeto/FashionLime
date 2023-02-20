 class Merchant::RegistrationsController < Devise::RegistrationsController

  include Modules::DeviseHelpersLib
  include Modules::PasswordManagingController
  include Modules::MerchantControllerLib

  layout 'merchant'

  before_action :init_user

  append_before_filter :authenticate_as_merchant_admin, only: [:profile_users, :update_profile_users, :new_profile_user, :create_profile_user]
  append_before_filter :load_merchant, only: [:edit, :profile_users, :update_profile_users]
  append_before_filter :load_profile_users, only: [:profile_users, :update_profile_users]

  add_breadcrumb "Вход за търговци", :merchant_sessions_new_path, only: [:new]
  add_breadcrumb "Промяна на профил", :merchant_edit_path, only: [:edit, :update_profile]
  add_breadcrumb "Асоциирани потребители", :merchant_profile_users_path, only: [:profile_users, :update_profile_users, :new_profile_user]
  add_breadcrumb "Нов потребители", :merchant_profile_users_new_path, only: [:new_profile_user]

  def profile_users
  end

  def edit
    @show_password_field = false
    super
  end

  def update_profile_users
    @merchant.skip_validation = true
    result = @merchant.update_attributes(profile_users_params)
    @merchant.skip_validation = false
    if result
      redirect_to merchant_profile_users_path, notice: "Успешно редактиране."
    else
      render :profile_users
    end
  end

  def new_profile_user
    @user = User.new
  end

  def create_profile_user
    @user = current_merchant.users.create(profile_user_params)
    unless @user.valid?
      render :new_profile_user
      return
    end
    @user.assign_merchant_role
    @user.assign_merchant_profile

    redirect_to merchant_profile_users_path, notice: 'Потребителят беше създаден.'
  end

  def update_profile
    update_user_profile(current_user)
  end

  protected

  def after_update_profile_path_for(user)
    merchant_root_path
  end

  def build_resource(hash=nil)
    super
    # Create an instance var to use just for the sign up form
    @sign_up_user = self.resource
  end

  def after_sign_up_path_for(resource)
    merchant_root_path
  end

  def after_update_path_for(resource)
    merchant_root_path
  end

  def load_merchant
    @merchant = current_merchant
  end

  def load_profile_users
    @users = current_merchant.users.where.not(id: current_user.id)
  end

  def sign_up_params
    res = super
    res[:validate_email_presence] = true
    res
  end

  def account_update_params
    res = super
    res[:validate_email_presence] = true
    res[:current_password] = res[:current_password_o]
    res.delete(:current_password_o)
    res
  end

  def profile_user_params
    pars = params.require(:user).permit(:username,
      :first_name,
      :last_name,
      :email,
      :password)
    pars[:validate_email_presence] = true
    pars[:email_promotions] = false
    return pars
  end

  def profile_users_params
    pars = params.require(:merchant).permit(
      users_attributes: [:id, :status])
  end

  def sections
    [:my_menu, :edit_profile]
  end
end

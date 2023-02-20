 class Merchant::PasswordsController < Devise::PasswordsController

  include Modules::DeviseHelpersLib
  include Modules::PasswordManagingController
  include Modules::MerchantControllerLib

  layout 'merchant'

  before_action :init_user

  skip_before_action :require_no_authentication, only: [:edit_password, :update_password]

  add_breadcrumb "Промяна на парола", :merchant_password_edit_path, only: [:edit_password, :update_password]

  def edit_password
    @user = current_user
  end

  def update_password
    udpate_user_password(current_user)
  end

  protected

  def after_update_password_path_for(user)
    merchant_root_path
  end

  def sections
    [:my_menu]
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

end

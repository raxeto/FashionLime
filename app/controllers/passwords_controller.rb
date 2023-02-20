 class PasswordsController < Devise::PasswordsController

  include Modules::MerchantLib
  include Modules::DeviseHelpersLib
  include Modules::PasswordManagingController
  include Modules::ClientControllerLib

  append_before_filter :authenticate_as_non_guest, only: [:edit_password, :update_password]
  skip_before_action :require_no_authentication, only: [:edit_password, :update_password]

  add_breadcrumb "Забравена парола", :new_user_password_path, only: [:new]
  add_breadcrumb "Промяна на парола", :users_edit_password_path, only: [:edit_password, :update_password]
  add_breadcrumb "Възстановяване на парола", :edit_user_password_path, only: [:edit, :update]

  def edit_password
    @user = current_user
  end

  def update_password
    udpate_user_password(current_user)
  end

  protected

  def after_update_password_path_for(user)
    root_path
  end

  def sections
    [:my_menu, :edit_password]
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

end

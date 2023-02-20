class AdminController < ApplicationController

  append_before_filter :authenticate_as_admin

  protected

  def authenticate_as_admin
    if !user_signed_in? || !current_user.admin?
      redirect_to root_path
    end
  end

end

class ApplicationController < ActionController::Base

  include Modules::ClientLib
  include Modules::CurrencyLib
  include Modules::NumberLib
  include Modules::StringLib
  include Modules::DateLib
  include Modules::PictureLib

  protect_from_forgery with: :exception


  before_action :temporary_close_site
  before_action :filter_inactive_user, except: [:ping]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_last_location, unless: :devise_controller?
  before_action :set_no_cache

  helper_method :current_or_guest_user, :current_profile, :current_user_admin?, :currency_unit, :num_to_currency, :num_to_currency_without_unit,
    :numbers_to_currency_range, :num_with_auto_precision, :date_time_to_s, :date_to_s, :truncate_string, :image_width,
    :image_height

  skip_before_action :verify_authenticity_token, only: [:ping]

  rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_bad_csrf_to_root

  def temporary_close_site
    render :nothing => true, :status => 503
  end

  def redirect_bad_csrf_to_root
    Rails.logger.info("InvalidAuthenticityToken: redirecting to root")
    redirect_to root_path
  end

  def ping
    render status: 200, text: "OK"
  end

  protected

  def set_no_cache
    # Disable caching, because browser back/forward messes up our JS.
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Sat, 01 Jan 2000 00:00:00 GMT"
  end

  def sections
    []
  end

  helper_method :sections

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:username,
               :email,
               :password,
               :email_o) }
    devise_parameter_sanitizer.for(:sign_in) { |u|
      u.permit(:username,
               :password,
               :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:username,
               :email,
               :email_o,
               :current_password_o,
               :first_name,
               :last_name,
               :gender,
               :phone,
               :avatar,
               :birth_date,
               :email_promotions)
    }
  end

  def set_last_location
    # Needed to return to the last visited page after sign in/sign up/edit/...
    if request.format.html?
      session["user_return_to"] = request.fullpath
    end
  end

  def get_last_location
    session["user_return_to"]
  end

  def filter_inactive_user
    if user_signed_in? && current_user.not_active?
      reset_session
      redirect_to root_path
    end
  end

end

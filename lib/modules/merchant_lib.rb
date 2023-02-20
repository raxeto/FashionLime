module Modules
  module MerchantLib

    protected

    def merchant_url_prefix
      return '/merchant'
    end

    def current_merchant
       current_user.merchant_user.merchant
    end

    def current_merchant_id
      current_merchant.id
    end

    def merchant_signed_in?
      user_signed_in? && current_user.merchant?
    end

    def merchant_admin_signed_in?
      user_signed_in? && current_user.merchant_admin?
    end

    def authenticate_as_merchant
      if user_signed_in?
        unless merchant_signed_in?
          redirect_to information_new_merchant_path, alert: I18n.t('controllers.merchant.log_out_customer_first')
        end
      else
        redirect_to merchant_sessions_new_path
      end
    end

    def authenticate_as_merchant_admin
      unless merchant_admin_signed_in?
        redirect_to merchant_sessions_new_path
      end
    end

    def authenticate_as_non_merchant
      if merchant_signed_in?
        redirect_to merchant_root_path
      end
    end

  end
end

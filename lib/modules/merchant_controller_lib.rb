module Modules
  module MerchantControllerLib

    extend ActiveSupport::Concern
    include Modules::MerchantLib

    included do
      append_before_filter :authenticate_as_merchant

      add_breadcrumb "Начало", :merchant_root_path

      helper_method :current_merchant
      helper_method :merchant_signed_in?

    end

  end
end

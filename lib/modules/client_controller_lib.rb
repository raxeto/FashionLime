module Modules
  module ClientControllerLib

    extend ActiveSupport::Concern
    include Modules::ClientUrlLib

    included do
      before_action :init_user
      helper_method :current_cart, :products_path, :products_url, :product_path, :product_url,
                    :outfit_path, :outfit_url, :outfits_path, :outfits_url,
                    :product_outfits_path,
                    :product_collection_path, :product_collection_url,
                    :search_page_path, :search_page_url,
                    :campaign_path, :campaign_url,
                    :return_order_path,
                    :remove_marketing_params

      helper SeoFriendlyImageHelper

      add_breadcrumb "Начало", :root_path

    end

  end
end

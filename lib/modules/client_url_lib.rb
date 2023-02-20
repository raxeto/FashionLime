module Modules
  module ClientUrlLib

    include Rails.application.routes.url_helpers

    protected

      def product_path(product)
        product_or_subcategory_path(product_url_params(product))
      end

      def product_url(product)
        product_or_subcategory_url(product_url_params(product))
      end

      def products_path(params = {})
        products_route(params, false)
      end

      def products_url(params = {})
        products_route(params, true)
      end

      def outfit_path(outfit)
        outfits_by_occasion_or_outfit_path(outfit_url_params(outfit))
      end

      def outfit_url(outfit)
        outfits_by_occasion_or_outfit_url(outfit_url_params(outfit))
      end

      def outfits_path(params = {})
        outfits_route(params, false)
      end
      def outfits_url(params = {})
        outfits_route(params, true)
      end

      def product_outfits_path(product)
        outfits_by_category_or_product_outfits_path(:category_or_product => product.to_client_param)
      end

      def product_collection_path(product_collection)
        merchant_profile_product_collection_path(product_collection_url_params(product_collection))
      end

      def product_collection_url(product_collection)
        merchant_profile_product_collection_url(product_collection_url_params(product_collection))
      end

      def search_page_path(params)
        search_page_route(params, false)
      end

      def search_page_url(params)
        search_page_route(params, true)
      end

      def return_order_path(merchant_order)
        new_return_order_path(return_order_url_params(merchant_order))
      end

      def return_order_url(merchant_order)
        new_return_order_url(return_order_url_params(merchant_order))
      end

      def campaign_path(campaign)
        campaign_show_path(campaign_url_params(campaign))
      end

      def campaign_url(campaign)
        campaign_show_url(campaign_url_params(campaign))
      end

      # Added in order to be used in modules and models.
      def default_url_options
        Rails.application.config.client_lib[:default_url_options]
      end

      def remove_marketing_params(path)
        begin
          uri = URI.parse(path)
          if uri.query.present?
            pars = URI.decode_www_form(uri.query)
            pars = pars.select { |p| !Conf.marketing.allowed_query_params.include?(p.first) }
            uri.query = URI.encode_www_form(pars)
            uri.query = nil if uri.query.blank? # Otherwise it adds ? to the end of the uri
          end
          uri.to_s
        rescue StandardError => e
          Rails.logger.error "Remove marketing params error with message: #{e.message}"
          path
        end
      end

    private

      def product_url_params(product)
        return {
          :category => ProductCategoryCache.master_category_url(product.product_category_id),
          :subcategory_or_product => product.to_client_param
        }
      end

      def outfit_url_params(outfit)
        return {
          :category_or_product => outfit.outfit_category.url_path,
          :occasion_or_outfit => outfit.to_client_param
        }
      end

      def product_collection_url_params(product_collection)
        return {
          :url_path => product_collection.merchant.url_path,
          :collection => product_collection.to_client_param
        }
      end

      def return_order_url_params(merchant_order)
        return {
          :return_code => merchant_order.return_code,
          :confirm_email => merchant_order.order.user_email
        }
      end

      def campaign_url_params(campaign)
        return {
          :campaign => campaign.to_client_param
        }
      end

      def products_route(params, absolute_path)
        if params[:c].blank?
          if absolute_path
            all_products_url(params)
          else
            all_products_path(params)
          end
        else
          pars = params.except(:c)
          cat_pars = ProductCategoryCache.product_category_url_params(params[:c])
          if cat_pars[:subcategory_or_product].blank?
            cat_pars = pars.merge(cat_pars)
            if absolute_path
              products_by_category_url(cat_pars)
            else
              products_by_category_path(cat_pars)
            end
          else
            if absolute_path
              product_or_subcategory_url(cat_pars)
            else
              product_or_subcategory_path(cat_pars)
            end
          end
        end
      end

      def outfits_route(params, absolute_path)
        p = {}
        outfit_pars = params
        unless params[:occasion].blank?
          p[:occasion_or_outfit] = params[:occasion].url_path
          outfit_pars = outfit_pars.except(:occasion)
        end

        unless params[:category].blank?
          p[:category_or_product] = params[:category].url_path
          outfit_pars = outfit_pars.except(:category)
        end
        unless params[:category_key].blank?
          category = OutfitCategory.find_by_key(params[:category_key])
          p[:category_or_product] = category.url_path
          outfit_pars = outfit_pars.except(:category_key)
        end


        if p.blank?
          if absolute_path
            return all_outfits_url(params)
          else
            return all_outfits_path(params)
          end
        end

        if !p[:category_or_product].blank?
          outfit_pars = p.merge(outfit_pars)
          if p[:occasion_or_outfit].blank?
            if absolute_path
              outfits_by_category_or_product_outfits_url(outfit_pars)
            else
              outfits_by_category_or_product_outfits_path(outfit_pars)
            end
          else
            if absolute_path
              outfits_by_occasion_or_outfit_url(outfit_pars)
            else
              outfits_by_occasion_or_outfit_path(outfit_pars)
            end
          end
        end
      end

      def search_page_route(params, absolute_path)
        search_page = params[:search_page]
        pars = params.except(:search_page).merge(:search_phrase => search_page.url_path)
        if search_page.product?
          if absolute_path
            products_search_page_url(pars)
          else
            products_search_page_path(pars)
          end
        elsif search_page.outfit?
          if absolute_path
            outfits_search_page_url(pars)
          else
            outfits_search_page_path(pars)
          end
        end
      end

  end
end

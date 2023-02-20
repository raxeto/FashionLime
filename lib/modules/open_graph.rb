module Modules
  class OpenGraph

    include Modules::ClientUrlLib

    def self.clear_cached_pages(model)
      open_graph = OpenGraph.new
      # TODO This is a temporary workaround for products import - because this is executed 5 time while inserting. Fix it!
      if model.is_a?(Product) && Modules::ProductMassUpdate.is_in_progress(model)
        Rails.logger.info("Skip clear Open Graph cache")
        return
      end
      Rails.logger.info("Clear Open Graph cache")
      url = open_graph.get_url_from_model(model)
      open_graph.clear_cache(url)
    end

    def clear_cache(url)
      rescrape_facebook(url)
    end
    handle_asynchronously :clear_cache

    def get_url_from_model(model)
      class_name = model.class.name
      case class_name
      when "Product"
        product_url(model)
      when "Outfit"
        outfit_url(model)
      when "ProductCollection"
        product_collection_url(model)
      when "OutfitSet"
         outfits_url(:category => model.outfit_category, :occasion => model.occasion)
      when "ProductCategory"
        if model.key == 'outfit'
          products_url
        else
          products_url(:c => model.key)
        end
      when "SearchPage"
        search_page_url(:search_page => model)
      when "Merchant"
        merchant_profile_url(model.url_path)
      when "User"
        user_profile_url(:url_path => model.url_path)
      end
    end

    def rescrape_facebook(url)
      Rails.logger.info("Scraping the url: #{url}")
      unless Rails.env.production?
        return
      end
      # Uncomment when test
      # uri = URI(url)
      # url = "http://9c2e5c4e.ngrok.io#{uri.path}"
      params = {
        :client_id => Conf.facebook.app_id,
        :client_secret => Conf.facebook.app_secret,
        :grant_type => "client_credentials"
      }
      uri = URI("https://graph.facebook.com/oauth/access_token?#{params.to_query}")
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)
      access_token = parsed_response["access_token"]
      unless access_token.nil?
        uri = URI('https://graph.facebook.com')
        res = Net::HTTP.post_form(uri, 'id' => "#{url}", 'scrape' => 'true',
            'access_token' => "#{access_token}", 'max' => '1000')
        Rails.logger.info("Scrape response #{res.code} #{res.body.try(:strip)} for #{url}")
      else
        Rails.logger.error("Failed to get access token #{parsed_response} #{url}")
      end
    end

  end
end


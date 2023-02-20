module Modules
  class OutfitJsonBuilder

    include Singleton
    include Modules::ClientUrlLib
    include Modules::ClientLib
    include Modules::CurrencyLib
    include SeoFriendlyImageHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::NumberHelper

    public

      attr_accessor :disabled

      def initialize
        @disabled = false
        super
      end

      def outfits_partial_data(outfits, user)
        res_outfits = []
        outfits.each do |o|
          res_outfits.push(thumb_partial_data(o, user))
        end
        return res_outfits
      end

      def thumb_partial_data(outfit, user)
        p = thumb_partial_data_cache(outfit.id)
        p[:user_rating] = outfit.cached_user_rating(user.profile.id, outfit.id) || 0
        p[:user_info] = {
          :profile_id => user.profile.id,
          :is_admin => user.admin?
        }
        p.to_json
      end

      def refresh_outfit_cache(outfit_id)
        if outfit_id.nil?
          Rails.logger.warn('Trying to update the cache for nil outfit ID')
          return
        end
        unless @disabled
          data = build_thumb_partial_data(outfit_id)
          refresh_outfit_cache_data(outfit_id, data)
        end
      end

      def refresh_outfit_cache_for_outfit(outfit)
        if outfit.nil?
          Rails.logger.warn('Trying to update the cache for nil outfit')
          return
        end
        unless @disabled
          data = build_thumb_partial_data_for_outfit(outfit)
          refresh_outfit_cache_data(outfit.id, data)
        end
      end

      def invalidate_outfit_cache(outfit_id)
        Rails.logger.info("Invalidating the outfit cache for ID#{outfit_id}")
        cache_key = generate_cache_key(outfit_id)
        Rails.cache.delete(cache_key)
      end

      def disable_cache
        Rails.logger.warn('Disabling the outfits cache')
        @disabled = true
      end

    private

      def refresh_outfit_cache_data(outfit_id, data)
        Rails.logger.info("Refreshing the outfit cache for outfit id: #{outfit_id}")
        cache_key = generate_cache_key(outfit_id)
        Rails.cache.write(cache_key, data)
        true
      end

      def generate_cache_key(outfit_id)
        "outfit_partial_cache_id_#{outfit_id}"
      end

      def thumb_partial_data_cache(outfit_id)
        cache_key = generate_cache_key(outfit_id)
        Rails.logger.info("Trying to fetch JSON for outfit ID#{outfit_id} from cache")
        Rails.cache.fetch(cache_key) do
          Rails.logger.info("Cache miss for key #{cache_key}")
          build_thumb_partial_data(outfit_id)
        end
      end

      def build_thumb_partial_data(outfit_id)
        build_thumb_partial_data_for_outfit(Outfit.find(outfit_id))
      end

      def build_thumb_partial_data_for_outfit(outfit)
        image_url = {}
        [:original, :medium, :thumb].each do |style|
          image_url[style] = outfit.picture.url(style)
        end
        return {
          :id => outfit.id,
          :name => outfit.name,
          :link => outfit_path(outfit),
          :edit_link => edit_outfit_path(outfit),
          :image_url => image_url,
          :image_alt => seo_image_description(:outfit, outfit),
          :profile_id => outfit.profile_id,
          :profile_name => outfit.profile.name,
          :profile_link => outfit.user.merchant? ? merchant_profile_path(outfit.user.merchant.url_path) : user_profile_path(:url_path => outfit.user.url_path),
          :rating => outfit.rating.to_i,
          :not_available => outfit.not_available?,
          :partly_available => outfit.partly_available?
        }
      end
  end
end


















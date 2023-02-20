module Modules
  class ProductJsonBuilder

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

      def products_partial_data(products, profile_id)
        res_products = []
        products.each do |p|
          res_products.push(thumb_partial_data(p, profile_id))
        end
        return res_products
      end

      def thumb_partial_data(product, profile_id)
        p = thumb_partial_data_cache(product.id)
        p[:user_rating] = product.cached_user_rating(profile_id, product.id) || 0
        p.to_json
      end

      def refresh_product_cache(product_id)
        if product_id.nil?
          Rails.logger.warn('Trying to update a nil product ID')
          return
        end
        unless @disabled
          data = build_thumb_partial_data(product_id)
          refresh_product_cache_data(product_id, data)
        end
      end

      def refresh_product_cache_for_product(product)
        if product.nil?
          Rails.logger.warn('Trying to update a nil product')
          return
        end
        unless @disabled
          data = build_thumb_partial_data_for_product(product)
          refresh_product_cache_data(product.id, data)
        end
      end

      def invalidate_product_cache(product_id)
        Rails.logger.info("Invalidating the product cache for ID#{product_id}")
        cache_key = generate_cache_key(product_id)
        Rails.cache.delete(cache_key)
      end

      def disable_cache
        Rails.logger.warn('Disabling the product cache')
        @disabled = true
      end

    private

      def refresh_product_cache_data(product_id, data)
        Rails.logger.info("Refreshing the product cache for product id: #{product_id}")
        cache_key = generate_cache_key(product_id)
        Rails.cache.write(cache_key, data)
        true
      end

      def generate_cache_key(product_id)
        "product_partial_cache_id_#{product_id}"
      end

      def thumb_partial_data_cache(product_id)
        cache_key = generate_cache_key(product_id)
        Rails.logger.info("Trying to fetch JSON for product ID#{product_id} from cache")
        Rails.cache.fetch(cache_key) do
          Rails.logger.info("Cache miss for key #{cache_key}")
          build_thumb_partial_data(product_id)
        end
      end

      def build_thumb_partial_data(product_id)
        build_thumb_partial_data_for_product(Product.find(product_id))
      end

      def build_thumb_partial_data_for_product(p)
        active = p.available? && !p.not_active?
        if (!p.has_different_prices?(active: active) &&
          (p.price(active: active) - p.price_with_discount(active: active)).abs >= Conf.math.PRICE_EPSILON)
          deleted_price = num_to_currency(p.price(active: active))
        else
          deleted_price = ""
        end
        if active && !p.has_different_perc_discount?(active: active) && p.perc_discount(active: active) >= Conf.math.PRICE_EPSILON
          discount = "-" + number_to_percentage(p.perc_discount(active: active))
        else
          discount = ""
        end
        product_picture = p.main_product_picture
        if product_picture.nil?
          picture = Product::DefaultProductPicture.new
        else
          picture = product_picture.picture
        end
        image_url = {}
        [:original, :medium, :thumb].each do |style|
          image_url[style] = picture.url(style)
        end
        image_alt = seo_image_description(:product_picture, product_picture)
        return {
          id: p.id,
          link: product_path(p),
          image_url: image_url,
          image_alt: image_alt,
          picture_watermark_url: p.picture_watermark_url,
          name: p.name,
          merchant_name: p.merchant.name,
          merchant_link: merchant_profile_path(p.merchant.url_path),
          deleted_price: deleted_price,
          price: p.general_price_text(active: active),
          colors: p.colors_sort_by_pictures.map {|c| c.background_css()},
          discount: discount,
          available: p.available?,
          rating: p.rating.to_i,
          type: 'Product'
        }
      end
  end
end


















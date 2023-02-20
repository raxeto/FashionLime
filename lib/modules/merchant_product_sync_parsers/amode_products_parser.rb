module Modules
  module MerchantProductSyncParsers
    class AmodeProductsParser < BaseProductsParser
      AUTHORIZATION = 'ZmFzaGlvbmxpbWU6azhzenFUc2EzNDVH'
      ARTICLE_DEFAULT_QTY = 2

      FORBIDDEN_CATEGORIES = [
        "By Melina Fashion"
      ]

      public

        def fetch_content(scrape_url, http_authorization=nil)
          super(scrape_url, AUTHORIZATION)
        end

        def process(merchant, first_page_str)
          colorful_color_id = Color.find_by_key("colorful").try(:id)
          no_size_id = Size.find_by_key("standart").try(:id)
          category_hash = get_category_hash
          colors_hash = get_colors_hash(merchant)
          products = parse_page(first_page_str, merchant, colorful_color_id, no_size_id, category_hash, colors_hash)
          return products
        end

        def parse_page(page_str, merchant, colorful_color_id, no_size_id, category_hash, colors_hash)
          json_object = parse_json(page_str)
          products = []
          json_object["data"].each do |product_json|
            p = parse_product(product_json, merchant, colorful_color_id, no_size_id, category_hash, colors_hash)
            if p.present?
              products << p
            end
          end
          if json_object["pagination"]["next"].present?
            next_page_str = fetch_content(json_object["pagination"]["next"])
            next_page_products = parse_page(next_page_str, merchant, colorful_color_id, no_size_id, category_hash, colors_hash)
            products.push(*next_page_products)
          end
          return products
        end

        def parse_product(product_json, merchant, colorful_color_id, no_size_id, category_hash, colors_hash)
          p = {}
          p[:name] = product_json["name"]
          p[:description] = strip_tags(product_json["description"])

          category = product_json["category"]["name"]
          if FORBIDDEN_CATEGORIES.include?(category)
            return nil
          end

          p[:product_category_id] = get_category_id(merchant, category_hash, category, p[:name])

          p[:articles] = [{
            :color_id => get_color_id(colors_hash, p[:name], colorful_color_id),
            :size_id => no_size_id,
            :price => product_json["original_price"]["formatted_without_symbol"].to_f,
            :price_with_discount => product_json["price"]["formatted_without_symbol"].to_f,
            :sku => product_json["id"].to_s,
            :qty => ARTICLE_DEFAULT_QTY
          }]

          pictures = []
          product_json["images"].each do |image_json|
            pictures << {
              :source_url => image_json["gallery"],
              :outfit_compatible => false
            }
          end
          p[:product_pictures] = pictures

          return p
        end

        def get_category_hash
          ret = {}
          ret["чанта"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["чантичка"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["чантична"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["протмоне"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["раница"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["шал"] = ProductCategory.find_by_key("women_scarfs").try(:id)
          ret["гривна"] = ProductCategory.find_by_key("women_bracelets").try(:id)
          ret["гривни"] = ProductCategory.find_by_key("women_bracelets").try(:id)
          ret["колие"] = ProductCategory.find_by_key("women_necklace").try(:id)
          ret["колан"] = ProductCategory.find_by_key("women_belts").try(:id)
          ret["гердан"] = ProductCategory.find_by_key("women_necklace").try(:id)
          ret["amode spain scottish style"] = ProductCategory.find_by_key("women_bags").try(:id)
          ret["клъч"] = ProductCategory.find_by_key("women_bags").try(:id)
          return ret
        end

        def get_category_id(merchant, category_hash, category, name)
          if category == "OUTLET" || category == "АКСЕСОАРИ" || category == "АКСЕСОАРИ - Amode"
            category_hash.each do |k, v|
              if Modules::StringLib.unicode_downcase(name).include?(k)
                return v
              end
            end
          else
            return apply_db_mapping(merchant, "ProductCategory", category)
          end
          return nil
        end

        def get_colors_hash(merchant)
          ret = {}
          MerchantProductApiMapping.where(:merchant_id => merchant.id, :object_type => "Color").each do |mp|
            ret[Modules::StringLib.unicode_downcase(mp.input_value)] = mp.object_id
          end
          return ret
        end

        def get_color_id(colors_hash, name, colorful_color_id)
          colors_hash.each do |k, v|
            if Modules::StringLib.unicode_downcase(name).include?(k)
              return v
            end
          end
          Rails.logger.info("We couldn't get color for merchant Amode and product with name #{name}.")
          return colorful_color_id
        end
    end
  end
end


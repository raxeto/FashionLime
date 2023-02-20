module Modules
  module MerchantProductSyncParsers
    class SouvenirProductsParser < BaseProductsParser

      FORBIDDEN_SKUS = [
        "13032",
        # Duplicate products with different colors
        "13136",
        "17196"
      ]

      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          
          colorful_color_id = Color.find_by_key("colorful").try(:id)
          trade_mark_id = TradeMark.find_by_key("souvenir_fashion").try(:id)
          categories = get_categories_mapping(doc)
          product_color_mappings = get_existing_product_colors(merchant)
          
          products = []
          doc.xpath("//SHOPITEM").each do |product_xml|
            p = parse_product(product_xml, merchant, colorful_color_id, trade_mark_id, categories, product_color_mappings)
            if p.present?
              products << p
            end
          end

          return products
        end

        def parse_product(product_xml, merchant, colorful_color_id, trade_mark_id, categories, product_color_mappings)
          p = {}
          p[:name] = parse_content(product_xml, "PRODUCT_NAME_L1")
          sku = parse_content(product_xml, "REFERENCE")
          if FORBIDDEN_SKUS.include?(sku)
            return nil
          end

          p[:description] = "Реф.номер: #{sku}; #{strip_tags(parse_content(product_xml, "DESCRIPTION_SHORT_L1"))}" 
          p[:trade_mark_id] = trade_mark_id

          category_id = parse_content(product_xml, "CATEGORY_DEFAULT").strip
          category = categories[category_id]
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)

          pictures_str = parse_content(product_xml, "IMAGES")
          pictures = []
          pictures_str.split("|.|").each do |pic_url|
            if is_url_valid(pic_url)
              pictures << {
                :source_url => pic_url,
                :outfit_compatible => false
              }
            end
          end
          p[:product_pictures] = pictures

          articles = []
          qtys = parse_content(product_xml, "ATTRIB_QUANT").split("|.|")
          sizes_str = parse_content(product_xml, "ATTRIB_GROUPS")
          ind = 0
          sizes_str.split("|:||.||:|").each do |size|
            if size == "|!|"
              Rails.logger.info("Product with sku #{sku} has empty size.")
              return nil
            end
            price = parse_content(product_xml, "PRICE")
            articles << {
              :color_id => product_color_mappings.key?(sku) ? product_color_mappings[sku] : colorful_color_id,
              :size_id => apply_db_mapping(merchant, "Size", size),
              :price => price,
              :price_with_discount => price,
              :sku => sku,
              :qty => qtys[ind].to_i
            }
            ind = ind + 1
          end
          
          p[:articles] = articles

          return p
        end

        def get_categories_mapping(doc)
          categories = {}
          doc.xpath("//CATEGORIES").each do |category_xml|
            categories[parse_content(category_xml, "CATEGORY_IMG_IDS")] = parse_content(category_xml, "CATEGORY_NAME_L1").strip
          end
          return categories
        end

        def get_existing_product_colors(merchant)
          product_color_mappings = {}
          Product.includes(:articles).where(:merchant_id => merchant.id).each do |p|
            article = p.articles.first
            sku = article.sku
            if sku.present?
              if product_color_mappings.key?(sku)
                Rails.logger.info("Product #{p.name} with sku #{sku} dublicates")
              end
              product_color_mappings[sku] = article.color_id
            end
          end
          return product_color_mappings
        end
    end
  end
end


module Modules
  module MerchantProductSyncParsers
    class BohoProductsParser < BaseProductsParser
      FORBIDDEN_PRODUCTS = [
        "Гривна от балийско дърво Alankar Art"
      ]
      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          # There is only one namespace so it's save to call remove_namespaces in order to skip xmlns: in xpath syntax
          doc.remove_namespaces!

          site_url = parse_content(doc, "//StoreUrl")
          trade_mark_id = TradeMark.find_by_name("Boho").try(:id)
          no_size_id = Size.find_by_key("standart").try(:id)
          colorful_color_id = Color.find_by_key("colorful").try(:id)

          products = []
          doc.xpath("//Product").each do |product_xml|
            p = parse_product(product_xml, merchant, trade_mark_id, no_size_id, colorful_color_id, site_url)
            if p.present?
              products << p
            end
          end

          return products
        end

        def parse_product(product_xml, merchant, trade_mark_id, no_size_id, colorful_color_id, site_url)
          p = {}
          p[:name] = parse_content(product_xml, "ProductName/BG")
          if FORBIDDEN_PRODUCTS.include?(p[:name])
            return nil
          end

          p[:description] = strip_tags(parse_content(product_xml, "ProductDescription/BG"))
          p[:trade_mark_id] = trade_mark_id
          category_1 = p[:name].split(' ').first
          category_2 = p[:name].split(' ').second

          p[:product_category_id] = apply_db_mapping_with_conditional_error(merchant, "ProductCategory", category_1, false)
          if p[:product_category_id].blank?
            p[:product_category_id] = apply_db_mapping_with_conditional_error(merchant, "ProductCategory", category_2, false)
          end

          if p[:product_category_id].blank?
            log_error("No category mapping for product with name #{p[:name]}")
          end
          
          category_branch = parse_content(product_xml, "Category/CategoryBranch/BG")
          # No error if collection is not found
          p[:product_collection_id] = apply_db_mapping_with_conditional_error(merchant, "ProductCollection", category_branch.split("|").first, false)

          articles = []
          variants = product_xml.at_xpath("ProductVariants")
          if variants.present?
            variants.xpath("ProductVariant").each do |variant|
              color = parse_content(variant, ".//OptionName/BG")
              # A, B, C, D variant case (http://boho.bg/product/1025/kolie-ot-muransko-staklo-cuore.html) Skip it!
              if color.length == 1
                Rails.logger.info("Skipping product #{p[:name]} because the color #{color} is not acceptable.")
                next
              end
              price = parse_content(variant, "ProductVariantPrice").to_f
              articles << {
                :size_id => no_size_id,
                :color_id => apply_db_mapping(merchant, "Color", color),
                :price => price,
                :price_with_discount => price,
                :sku => parse_content(variant, "ProductVariantCode"),
                :qty => parse_content(variant, "ProductVariantQuantity").to_f
              }
            end
          else
            price = parse_content(product_xml, "ProductPrice").to_f
            articles << {
              :size_id => no_size_id,
              :color_id => colorful_color_id,
              :price => price,
              :price_with_discount => price,
              :sku => parse_content(product_xml, "ProductCode"),
              :qty => parse_content(product_xml, "ProductQuantity").to_f
            }
          end

          p[:articles] = articles

          pictures = []
          product_xml.xpath(".//ImagePath").each do |image_url|
            pictures << {
              :source_url => URI.join(site_url, image_url.content.to_s).to_s,
              :outfit_compatible => false,
              :color_id => articles.size > 0 ? articles.first[:color_id] : nil
            }
          end
          p[:product_pictures] = pictures
          return p
        end
    end
  end
end


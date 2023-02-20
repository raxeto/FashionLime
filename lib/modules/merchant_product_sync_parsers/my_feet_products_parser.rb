module Modules
  module MerchantProductSyncParsers
    class MyFeetProductsParser < BaseProductsParser

      FORBIDDEN_CATEGORIES = [
        "Ортопедична", 
        "Ортопедочна", 
        "Анатомична", 
        "Спортна", 
        "Хигиенна", 
        "Зимна", 
        "Пяна", 
        "Четка-пяна",
        "Импрегниращ",
        "Импрегнант",
        "Спрей",
        "Дезедорант",
        "Неутрална",
        "Цветна",
        "Стик-боя",
        "Гъба",
        "Обувалка",
        "Препарат",
        "Боя"
      ]

      HEEL_HIGH_MIN = 7.0

      public
        def process(merchant, file_str)
          if file_str.include?("Service is temporarily unavailable")
            raise "We couldn't get MyFeet products feed."
          end
          doc = parse_xml(file_str)
          colorful_color_id = Color.find_by_key("colorful").try(:id)
          low_shoes_id = ProductCategory.find_by_key("low_shoes").id
          high_shoes_id = ProductCategory.find_by_key("high_shoes").id
          products = []
          doc.xpath("//product").each do |product_xml|
            product = parse_product(product_xml, merchant, colorful_color_id, low_shoes_id, high_shoes_id)
            if product.present?
              products << product
            end
          end
          return products
        end

        def parse_product(product_xml, merchant, colorful_color_id, low_shoes_id, high_shoes_id)
          p = {}
          p[:name] = parse_content(product_xml, "descriptions/descriptions/name")
          p[:description] = strip_tags(parse_content(product_xml, "descriptions/descriptions/description"))

          price = (parse_content(product_xml, "price").to_f * 1.2).round(2) # price is with no taxes
          price_with_discount = parse_content(product_xml, "price_sale").to_f
          # There are products with 0.0 price - we have to exclude them
          if price == 0.0 || price_with_discount == 0.0
            return nil
          end

          category = p[:name].split(' ').first.strip
          if FORBIDDEN_CATEGORIES.include?(category)
            return nil
          end
          product_category_id = apply_db_mapping(merchant, "ProductCategory", category)
          if product_category_id == low_shoes_id
            if are_high_shoes(p[:description])
              product_category_id = high_shoes_id
            end
          end
          p[:product_category_id] = product_category_id

          p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", parse_content(product_xml, "manufacturer_name"))

          product_id = parse_content(product_xml, "product_id")
          color_id = get_color(p[:name], p[:description], merchant, colorful_color_id)

          articles = []
          product_xml.xpath("attributes/*").each do |article_xml|
            size = parse_content(article_xml, "attribute_name")
            articles << {
              :size_id => apply_db_mapping(merchant, "Size", size),
              :color_id => color_id,
              :price => price,
              :price_with_discount => price_with_discount,
              :sku => product_id,
              :qty => parse_content(article_xml, "quantity").to_f
            }
          end
          p[:articles] = articles

          pictures = []
          product_xml.xpath("images/image").each do |image|
            pictures << {
              :source_url => image.content,
              :outfit_compatible => false,
              :color_id => color_id
            }
          end
          p[:product_pictures] = pictures
          return p
        end

        def get_color(name, description, merchant, colorful_color_id)
          # 1. Get it from description
          descr_lines = description.split("\n")
          color_ind = descr_lines.index("Цвят")
          if color_ind.present?
            return apply_db_mapping(merchant, "Color", descr_lines[color_ind + 1])
          end
          # 2. Get it from name
          last_digit = name.rindex(/\d/)
          if last_digit.present?
            color_ind = last_digit + 1
            color_name = name[color_ind..-1].try(:strip)

            if color_name.present?
              return apply_db_mapping(merchant, "Color", color_name)
            end
          end
          return colorful_color_id
        end

        def are_high_shoes(description)
          descr_lines = description.split("\n")
          heel_ind = descr_lines.index("Височина на ток")
          if heel_ind.present?
            heel_high = descr_lines[heel_ind + 1].to_f
            return heel_high >= HEEL_HIGH_MIN
          elsif description.include?("на висок ток")
            return true
          end
          return false
        end
    end
  end
end


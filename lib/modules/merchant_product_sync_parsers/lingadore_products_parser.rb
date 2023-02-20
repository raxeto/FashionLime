module Modules
  module MerchantProductSyncParsers
    class LingadoreProductsParser < BaseProductsParser

      FORBIDDEN_CATEGORIES = [
        "Ежедневни дрехи > Пижами",
        "Ежедневни дрехи > Нощници",
        "Бански костюми > Бански аксесоари",
        "Ежедневни дрехи > Халати",
        "Аксесоари > Ботушки",
        "Бански костюми > Детски бански",
        "Аксесоари > Кламери за сутиен",
        "Бански костюми > Дрехи за плажа",
        "Ежедневни дрехи > Фини нощници",
        "Ежедневни дрехи > Фини пижами",
        "Аксесоари > Чанта за сутиен",
        "Ежедневни дрехи > Нощници фини",
        "Ежедневни дрехи > нощница сатен"
      ]

      FORBIDDEN_SIZES = [
        "128",
        "140"
      ]

      FORBIDDEN_PRODUCTS = [
        "15"
      ]

      SPECIAL_MESSAGE_CATEGORIES = [
        "Бански костюми > Бански долнища",
        "Дамско бельо > Бикини",
        "Дамско бельо > Боксери",
        "Дамско бельо > Стринг (прашки)"
      ]

      SPECIAL_MESSAGE = "!!! ПОРАДИ ДЕЛИКАТНИЯ ХАРАКТЕР НА МОДЕЛА И С ВНИМАНИЕ КЪМ ЗДРАВЕТО НА КЛИЕНТА, НЯМА ДА МОЖЕМ ДА ПРИЕМЕМ ВРЪЩАНЕТО НА ТОЗИ ПРОДУКТ."

      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          # There is only one namespace so it's save to call remove_namespaces in order to skip xmlns: in xpath syntax
          doc.remove_namespaces!

          products = []
          doc.xpath("//item").each do |product_xml|
            product = parse_product(product_xml, merchant)
            if product.present?
              products << product
            end
          end
          return products
        end

        def parse_product(product_xml, merchant)
          p = {}
          
          product_id = parse_content(product_xml, "id")
          if FORBIDDEN_PRODUCTS.include?(product_id)
            return nil
          end

          category = parse_content(product_xml, "product_category").squish
          if FORBIDDEN_CATEGORIES.include?(category)
            return nil
          end
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)

          p[:name] = parse_content(product_xml, "title")
          
          p[:description] = CGI.unescapeHTML(strip_tags(parse_content(product_xml, "description").gsub("&amp;", "&")))
          if SPECIAL_MESSAGE_CATEGORIES.include?(category)
            p[:description] = "#{p[:description]} #{SPECIAL_MESSAGE}"
          end

          p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", parse_content(product_xml, "brand"))
          
          articles = []
          product_xml.xpath("group_sizes/sizes").each do |article_xml|
            size = parse_content(article_xml, "size")
            if FORBIDDEN_SIZES.include?(size)
              next
            end
            color = parse_content(article_xml, "color")
            if color.blank?
              return nil
            end
            price_element = article_xml.at_xpath("sale_price")
            price = price_element.present? ? price_element.content.to_f : 0.0
            price_with_discount = parse_content(article_xml, "price").try(:to_f) || 0.0
            article = {
                :size_id => apply_db_mapping(merchant, "Size", size),
                :color_id => apply_db_mapping(merchant, "Color", color),
                :price => price > 0.0 ? price : price_with_discount,
                :price_with_discount => price_with_discount,
                :sku => product_id,
                :qty => parse_content(article_xml, "qty").to_f
            }
            articles << article
          end

          # Articles.uniq because a case with the same articles xml twice
          # https://www.lingadore.bg/lingadore-damski-banski-kostyum-komplekt-2314w-151
          p[:articles] = articles.uniq

          pictures = [{
            :source_url => parse_content(product_xml, "image_link")
          }]
          product_xml.xpath(".//additional_image_link").each do |image_url|
            pictures << {
              :source_url => image_url.content,
              :get_with_open_uri => true
            }
          end
          pictures.each do |pic|
            pic[:outfit_compatible] = false
            pic[:color_id] = articles.size > 0 ? articles.first[:color_id] : nil
          end
          p[:product_pictures] = pictures
          return p
        end
    end
  end
end


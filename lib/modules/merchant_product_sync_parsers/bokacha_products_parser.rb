module Modules
  module MerchantProductSyncParsers
    class BokachaProductsParser < BaseProductsParser
      FORBIDDEN_CATEGORIES = [
        "Дамски+Аксесоари за телефон",
        "Дамски+Детски медальони, колиета, висулки, синджири",
        "Дамски+Луксозни подаръци",
        "Дамски+Луксозни подаръци за мъже",
        "Дамски+Мъжки часовници",
        "Дамски+Подарък за Свети Валентин",
        "Дамски+Размер L",
        "Дамски+Размер M",
        "Дамски+Размер S",
        "Дамски+Размер XL"
      ]

      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)

          no_size_id = Size.find_by_key("standart").try(:id)
          products_sku_hash = {}

          doc.xpath("//product").each do |product_xml|
            parse_product(product_xml, merchant, products_sku_hash, no_size_id)
          end

          products = products_sku_hash.values

          return products
        end

        def parse_product(product_xml, merchant, products_sku_hash, no_size_id)
          p = {}
          p[:name] = parse_content(product_xml, "name")
          # CGI.unescapeHTML is used to replace &lt; and &gt; with < and > back.
          p[:description] = CGI.unescapeHTML(strip_tags(parse_content(product_xml, "description")))

          trade_mark = parse_content(product_xml, "trademark").strip
          if trade_mark.present?
            p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", trade_mark)
          end
          category = parse_content(product_xml, "category")
          # TODO Skip the empty category for now - wait the Maria reply. 69 articles.
          if category == "Дамски+"
            return
          end
          # Skip Ключодържатели, Брошки & Мъже, Деца
          if category.start_with?("Мъжки+", "Детски+", "Унисекс+") || category.include?("Ключодържатели") || category.include?("Брошки") || FORBIDDEN_CATEGORIES.include?(category)
            return
          end
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)

          # Gets only the first occasion. The second is not mapped and can't be.
          occasion = parse_content(product_xml, "occasions/occasion")
          if occasion.present?
            p[:occasion_ids] = [
              apply_db_mapping(merchant, "Occasion", occasion)
            ]
          end
          parent_sku = parse_content(product_xml, "sku_parent")

          articles = []
          product_xml.xpath("articles/article").each do |article_xml|
            size = parse_content(article_xml, "size")
            size_id = 0
            if size.present?
              size_id = apply_db_mapping(merchant, "size", size).to_i
            else
              if category == "Дамски+Комплекти" || category == "Дамски+Комплекти Бижута"
                size_id = no_size_id
              end
            end

            color = parse_content(article_xml, "color")
            if color.nil? || color.length == 0 || color == "Без камък"
              return # TODO Skip for now - wait Maria repry. 63 products.
            end

            price = parse_content(article_xml, "price")
            price_with_discount = parse_content(article_xml, "price_with_discount")

            if price.to_f < price_with_discount.to_f
              Rails.logger.info("The price with discount is less than the price without discount. Product SKU: #{parent_sku}.")
              price_with_discount = price
            end

            articles << {
                :size_id => size_id,
                :color_id => apply_db_mapping(merchant, "Color", color),
                :price => price,
                :price_with_discount => price_with_discount.present? ? price_with_discount : price,
                :sku => parse_content(article_xml, "sku"),
                :qty => parse_content(article_xml, "qauntity").to_f
            }
          end

          p[:articles] = articles

          pictures = []
          product_xml.xpath("pictures/picture/url").each do |image_url|
            if image_url.content.present? && image_url.content.to_s != "https://www.bokacha.com/pub/media/catalog/product/no_selection"
              pictures << {
                :source_url => image_url.content.to_s,
                :outfit_compatible => false,
                :color_id => articles.size > 0 ? articles.first[:color_id] : nil
              }
            end
          end
          p[:product_pictures] = pictures

          if products_sku_hash.key?(parent_sku)
            product = products_sku_hash[parent_sku]
            existing_articles = product[:articles]
            if existing_articles.first[:size_id] == 0
              # First product of products with more than 1 article is invalid (with no size)
              # So we should remove it
              existing_articles.shift
            end
            product[:articles] = existing_articles + articles
          else
            products_sku_hash[parent_sku] = p
          end
        end
    end
  end
end


module Modules
  module MerchantProductSyncParsers
    class MaryettProductsParser < BaseProductsParser

      ARTICLE_DEFAULT_QTY = 2
    
      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          colorful_color_id = Color.find_by_key("colorful").try(:id)
          no_size_id = Size.find_by_key("standart").try(:id)

          products = []
          doc.xpath("//product").each do |product_xml|
            products << parse_product(product_xml, merchant, colorful_color_id, no_size_id)
          end
          return products
        end

        def parse_product(product_xml, merchant, colorful_color_id, no_size_id)
          p = {}
          p[:name] = parse_content(product_xml, "name")
          p[:description] = strip_tags(parse_content(product_xml, "description"))
          p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", parse_content(product_xml, "trademark"))
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", parse_content(product_xml, "category"))


          articles = []
          has_no_size = false
          product_xml.xpath("articles/article").each do |article_xml|
            color_tag = article_xml.at_xpath("color")
            color_id = color_tag.present? ? apply_db_mapping(merchant, "Color", color_tag.content) : colorful_color_id
            size = parse_content(article_xml, "size").strip
            if size == "Изчерпан модел"
              next
            end
            size_id = apply_db_mapping(merchant, "Size", size)
            if size_id == no_size_id
              has_no_size = true
            end
            articles << {
              :color_id => color_id,
              :size_id => size_id,
              :price => parse_content(article_xml, "price").to_f,
              :price_with_discount => parse_content(article_xml, "price_with_discount").to_f,
              :sku => parse_content(article_xml, "sku"),
              :qty => ARTICLE_DEFAULT_QTY
            }
          end
          
          if has_no_size && articles.size > 1
            articles = articles.reject {|a| a[:size_id] == no_size_id} 
          end

          p[:articles] = articles

          pictures = []
          product_xml.xpath("pictures/picture").each do |picture_xml|
            pictures << {
              :source_url => parse_content(picture_xml, "url"),
              :color_id => articles.size > 0 ? articles.first[:color_id] : nil,
              :outfit_compatible => false
            }
          end
          p[:product_pictures] = pictures

          return p
        end
    end
  end
end


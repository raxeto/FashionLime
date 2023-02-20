module Modules
  module MerchantProductSyncParsers
    class KamiProductsParser < BaseProductsParser

      ARTICLE_DEFAULT_QTY = 2
      EXISTING_SKU_TO_COLOR_MAPPING = {
        '998' => '10',
        '62100' => '2',
        '997' => '2',
        '1001' => '11',
        '994' => '8',
        '996' => '8',
        '992' => '3',
        '1003' => '7',
        '9882' => '10',
        '1004' => '4',
        '82111' => '10',
        '1000' => '3',
        '8986' => '1',
        '7484' => '1',
        '991' => '3',
        '9726' => '1',
        '1020' => '8',
        '1122' => '11',
        '8558' => '11',
        '9755' => '6',
        '9722' => '3',
        '5200' => '4',
        '9344' => '8',
        '9303' => '7',
        '9301' => '5',
        '8359' => '6',
        '828' => '11',
        '926' => '2',
        '921' => '1',
        '911' => '2',
        '933' => '3',
        '8088' => '1',
        '892' => '3',
        '909' => '1',
        '9044' => '6',
        '5851' => '10',
        '841' => '10',
        '9144' => '11',
        '5878' => '4',
        '971' => '10',
        '903' => '6',
        '980' => '10',
        '904' => '4',
        '931' => '1',
        '895' => '3',
        '906' => '6',
        '9577' => '10',
        '9300' => '10',
        '9118' => '3'
      }

      public
        def process(merchant, file_str)
          # The scrape url cause refreshing of the file. But then we should get it
          file_str = Net::HTTP::get( URI("http://kami2000store.com/xml_files/fashionlime.xml"))
          doc = parse_xml(file_str)
          colorful_color_id = Color.find_by_key("colorful").try(:id)
          products = []
          doc.xpath("//product").each do |product_xml|
            p = parse_product(product_xml, merchant, colorful_color_id)
            if p.present?
              products << p
            end
          end
          return products
        end

        def parse_product(product_xml, merchant, colorful_color_id)
          p = {}
          p[:name] = parse_content(product_xml, "name")
          p[:description] = strip_tags(parse_content(product_xml, "description"))
          p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", parse_content(product_xml, "trademark"))

          category = parse_content(product_xml, "category")
          if category.present?
            p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)
          else
            return nil
          end

          pictures = []
          product_xml.xpath("pictures/picture").each do |picture_xml|
            url_path = "http://" + parse_content(picture_xml, "url")
            if is_url_valid(url_path)
              pictures << {
                :source_url => url_path,
                :outfit_compatible => false
              }
            end
          end
          p[:product_pictures] = pictures

          articles_xml = product_xml.at_xpath("articles/article")
          sku = parse_content(articles_xml, "sku")

          price = parse_content(articles_xml, "price").to_f
          price_with_discount_xml = articles_xml.at_xpath("price_with_discount")
          price_with_discount = price_with_discount_xml.nil? ? price : price_with_discount_xml.content.to_f

          articles = []
          articles_xml.xpath("articles/article").each do |article_xml|
            articles << {
              :color_id => get_color_id(sku, colorful_color_id),
              :size_id => apply_db_mapping(merchant, "Size", parse_content(article_xml, "size")),
              :price => price,
              :price_with_discount => price_with_discount,
              :sku => sku,
              :qty => parse_content(article_xml, "is_available") == "true" ? ARTICLE_DEFAULT_QTY : 0.0
            }
          end
          p[:articles] = articles

          return p
        end

        def get_color_id(sku, colorful_color_id)
          if EXISTING_SKU_TO_COLOR_MAPPING.key?(sku)
            EXISTING_SKU_TO_COLOR_MAPPING[sku].to_i
          else
            colorful_color_id
          end
        end
    end
  end
end


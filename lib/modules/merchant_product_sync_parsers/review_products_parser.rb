module Modules
  module MerchantProductSyncParsers
    class ReviewProductsParser < BaseProductsParser

      ARTICLE_DEFAULT_QTY = 1
      FORBIDDEN_CATEGORIES = [
        # Not concrete enough - TODO for later maybe - get category from name
        "PRIMAVERA>АКСЕСОАРИ>Бижута",
        "АКСЕСОАРИ>Бижута>PRIMAVERA",
        "RADEKS>ЕЖЕДНЕВНИ ОБЛЕКЛА", 
        "ЕЖЕДНЕВНИ ОБЛЕКЛА>RADEKS",
        "Подаръчни ваучери",
        "SALE>RADEKS"
      ]
      FORBIDDEN_SKUS = [
        # Because of not unique articles (color's mapping)
        "6545",
        "6323/770",
        "LM-F34",
        "LMF34"
      ]
      TRADE_MARK_DISCOUNTS = {
        TradeMark.find_by_key("primavera").id => {
          :perc_discount => 50.0,
          :start_date => Date.new(2017, 8, 1),
          :end_date => Date.new(2017, 8, 31)
        },
        TradeMark.find_by_key("radeks").id => {
          :perc_discount => 30.0,
          :start_date => Date.new(2017, 8, 1),
          :end_date => Date.new(2017, 8, 31)
        },
      }

      PRODUCT_CATEGORY_DISCOUNTS = {
        ProductCategory.find_by_key("dresses").id => {
          :perc_discount => 20.0,
          :start_date => Date.new(2017, 10, 1),
          :end_date => Date.new(2017, 10, 31)
        },
        ProductCategory.find_by_key("women_coats").id => {
          :perc_discount => 10.0,
          :start_date => Date.new(2017, 11, 1),
          :end_date => Date.new(2017, 11, 10)
        }
      }
     
      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          products = []
          product_hash = {}
          doc.xpath("//product").each do |product_xml|
            p = parse_product(product_xml, merchant)
            if p.present? && !product_hash.key?(p[:sku])
              products << p[:product]
              product_hash[p[:sku]] = p[:product]
            end
          end
          product_names = {}
          product_skus = {}
          products.each do |p|
            if product_names.key?(p[:name])
              Rails.logger.info("Product with name #{p[:name]} has different SKUs.")
            else
              product_names[p[:name]] = p
            end
            if p[:articles][0].present?
              sku = p[:articles][0][:sku]
              if product_skus.key?(sku)
                log_error("Product with sku #{sku} has different products.")
              else
                product_skus[sku] = p
              end
            end
          end
          return products
        end

        def parse_product(product_xml, merchant)
          p = {}
          sku = parse_content(product_xml, "SKU")
          if sku.blank? || FORBIDDEN_SKUS.include?(sku)
            return nil
          end
          category = parse_content(product_xml, "Category")
          if FORBIDDEN_CATEGORIES.include?(category)
            return nil
          end
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)
          p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", parse_content(product_xml, "Brand"))
          p[:name] = parse_content(product_xml, "Product_title")
          p[:description] = parse_content(product_xml, "Descrition")

          price = parse_content(product_xml, "Price").to_f
          perc_discount = get_perc_discount(p[:trade_mark_id], p[:product_category_id])

          colors = []
          parse_content(product_xml, "Color").split(',').each do |color_xml|
            if color_xml.strip == "--"
              Rails.logger.info("Color empty for product with SKU #{sku}.")
              next
            end
            colors << apply_db_mapping(merchant, "Color", color_xml.strip)
          end
          sizes = []
          parse_content(product_xml, "Size").split(',').each do |size_xml|
            sizes << apply_db_mapping(merchant, "Size", size_xml.strip)
          end

          articles = []
          colors.each do |color_id|
            sizes.each do |size_id|
              articles << {
                :color_id => color_id,
                :size_id => size_id,
                :price => price,
                :perc_discount => perc_discount,
                :sku => sku,
                :qty => ARTICLE_DEFAULT_QTY
              }
            end
          end
       
          p[:articles] = articles

          pictures = []
          append_picture(product_xml, "Image", pictures, articles)
          append_picture(product_xml, "Image1", pictures, articles)
          append_picture(product_xml, "Image2", pictures, articles)
          append_picture(product_xml, "Image3", pictures, articles)
          p[:product_pictures] = pictures

          return { :sku => sku, :product => p }
        end

        def get_perc_discount(trade_mark_id, product_category_id)
          discount = TRADE_MARK_DISCOUNTS[trade_mark_id]
          if discount.present? && discount[:start_date] <= Time.zone.today && discount[:end_date] >= Time.zone.today 
            return discount[:perc_discount]
          end
          category_discount = PRODUCT_CATEGORY_DISCOUNTS[product_category_id]
          if category_discount.present? && category_discount[:start_date] <= Time.zone.today && category_discount[:end_date] >= Time.zone.today 
              return category_discount[:perc_discount]
            end
          return 0.0
        end

        def append_picture(product_xml, tag_name, pictures, articles)
          url = parse_content(product_xml, tag_name)
          if url.present? && url != "0"
            pictures << {
              :source_url => url,
              :outfit_compatible => false,
              :color_id => articles.size > 0 ? articles.first[:color_id] : nil
            }
          end
        end
    end
  end
end


module Modules
  module MerchantProductSyncParsers
    class HildonBrandParser < BaseProductsParser

      protected

        def parse_internal(merchant, file_str)
          xml_doc = parse_xml(file_str)
          products = []

          xml_doc.xpath("//product").each do |p|
            product_hash = parse_product(merchant, p)
            if product_hash.present?
              products << product_hash
            end
          end

          return products
        end

        def parse_product(merchant, product_tag)
          if product_tag.css('productstatus').first.content.strip == 'Draft'
            # A draft product - skip it
            return nil
          end

          if is_mans_fashion(product_tag)
            # We only serve women
            return nil
          end

          res = {}
          res[:name] = product_tag.css('productname').first.content.strip
          res[:product_category_id] = parse_product_category(product_tag, res[:name], merchant)
          if res[:product_category_id].blank?
            return nil
          end

          res[:description] = product_tag.css('description').first.content.strip
          if res[:description].blank?
            res[:description] = product_tag.css('excerpt').first.content.strip
          end
          res[:description] = strip_tags(res[:description])
          sku = product_tag.css('productid').first.content.strip
          price = product_tag.css('price').first.content.to_i
          res[:product_pictures] = parse_pictures(product_tag)
          qty = parse_qty(product_tag)
          size_ids = parse_sizes(product_tag)

          if size_ids.nil?
            return nil
          end

          price_with_discount = parse_discount(product_tag, price)

          res[:articles] = []
          size_ids.each do |size_id|
            res[:articles] << {
              price: price,
              color_id: Color.find_by(key: 'colorful').id,
              sku: sku,
              qty: qty,
              size_id: size_id,
              price_with_discount: price_with_discount
            }
          end

          res[:trade_mark_id] = nil
          res[:occasion_ids] = nil
          return res
        end

        def is_mans_fashion(product_tag)
          category = product_tag.css('category').first.content.strip
          if category.include?('Мъжки') || category.include?('мъжки')
            # This might be a product with variations for men and women
            if is_simple_product(product_tag)
              return true
            end
            attribute = get_active_attribute(product_tag)
            return !(attribute.include?('Дамска') || attribute.include?('дамска'))
          end
          return false
        end

        def get_active_attribute(product_tag)
          product_tag.css('attribute').each do |a|
            c = a.content.strip
            if c.present?
              return c
            end
          end
          return ''
        end

        def parse_product_category(product_tag, name, merchant)
          category = product_tag.css('category').first.content.strip()
          if match(category, ['Tattoos', 'tattoos'])
            return nil
          end

          category.split('|').each do |c|
            id = apply_db_mapping_with_conditional_error(merchant, 'ProductCategory', c, false)
            if id.present?
              return id
            end
          end

          if match(name, ['Гривна', 'гривна'])
            return ProductCategory.find_by(key: 'women_bracelets').try(:id)
          end
          if match(name, ['Амулет', 'амулет', 'Necklace', 'necklace'])
            return ProductCategory.find_by(key: 'women_necklace').try(:id)
          end

          if match(category, ['Бижута от Божи гроб'])
            return ProductCategory.find_by(key: 'women_necklace').try(:id)
          end

          log_error("Failed to match product category for #{product_tag.to_s}")
          return nil
        end

        def match(s, patterns)
          patterns.each do |p|
            if s.include?(p)
              return true
            end
          end
          return false
        end

        def is_simple_product(product_tag)
          product_tag.css('type').first.content.strip == 'Simple Product'
        end

        def parse_sizes(product_tag)
          if !is_simple_product(product_tag)
            # This is a variation. Parse the sizes
            # If there is a size for men and one for women, then we are good.
            attribute = get_active_attribute(product_tag)
            if (attribute.include?('Дамска') || attribute.include?('дамска')) && \
                (attribute.include?('Мъжка') || attribute.include?('мъжка'))
              Rails.logger.info("Product #{product_tag.css('productid').first.content.to_i} has male and female versions")
              return [Size.find_by(key: 'standart').try(:id)]
            end

            # We know of two products that have multiple sizes for women. Make
            # sure to notice if a new one is introduced.
            if ![4776, 4777].include?(product_tag.css('productid').first.content.to_i)
              log_error("A new product with variations has been added! #{product_tag}")
            end
            return nil
          end
          return [Size.find_by(key: 'standart').try(:id)]
        end

        def parse_qty(product_tag)
          # Currently we have no better way of getting the available qty than
          # setting it to 0 if it's out of stock and to 1 otherwise
          if product_tag.css('stockstatus').first.content.strip == 'In Stock'
            return 1
          end
          return 0
        end

        def parse_discount(product_tag, price)
          discounted_price = product_tag.css('saleprice').first.content.to_i || price
          if discounted_price == 0
            discounted_price = price
          end
          return discounted_price
        end

        def parse_pictures(product_tag)
          res = []
          t = product_tag.css('featuredimage').first.content.strip
          if t.present?
            res << {
              source_url: t,
              outfit_compatible: false,
              color_id: Color.find_by(key: 'colorful').id
            }
          end
          productgallery = product_tag.css('productgallery').first
          if productgallery.present?
            t = productgallery.content.strip
            t.split('|').each do |s|
              res << {
                source_url: s,
                outfit_compatible: false,
                color_id: Color.find_by(key: 'colorful').id
              }
            end
          end

          return res
        end
    end
  end
end

module Modules
  module MerchantProductSyncParsers
    class SibellebagsParser < BaseProductsParser
      AUTHORIZATION = 'OVdGSUtEQVIzNUdMRkFYNlYyNzJHWFo0WURGMTNHWk46'

      attr_accessor :women_bags_product_category_id, :women_hats_product_category_id, :women_scarfs_product_category_id

      def initialize
        super

        # Sibelle wants to set the discounts manually
        Rails.logger.info("Skipping discounts")
        @sync_discounts = false
      end

      def fetch_content(scrape_url, http_authorization=nil)
        super(scrape_url, AUTHORIZATION)
      end

      protected

        def parse_internal(merchant, file_str)
          xml_doc = parse_xml(file_str)
          products = []
          self.women_bags_product_category_id = ProductCategory.find_by_key('women_bags').id
          self.women_hats_product_category_id = ProductCategory.find_by_key('women_hats').id
          self.women_scarfs_product_category_id = ProductCategory.find_by_key('women_scarfs').id

          # Uncomment this if we want to set the discounts automatically
          # discounts = parse_discounts
          discounts = {}
          xml_doc.xpath("//product").each do |p|
            xml_product_content = fetch_xml(p['xlink:href'], AUTHORIZATION)
            products << parse_product(merchant, xml_product_content, discounts)
          end

          return products
        end

        def parse_product(merchant, product_xml, discounts)
          product_hash = {
            articles: []
          }
          price = product_xml.css('price').first.content.to_i
          product_id = product_xml.css('id').first.content.to_i
          sku = "#{product_xml.css('reference').first.content.strip}-#{product_id}"
          product_hash[:name] = parse_translated_text_tag(product_xml.css('name').first)
          product_hash[:description] = parse_translated_text_tag(product_xml.css('description').first)
          product_hash[:description] = strip_tags(product_hash[:description])
          associations = product_xml.css('associations').first

          combinations = parse_combinations(merchant, associations.css('combination'), sku)
          quantities = parse_qtys(associations.css('stock_available'))

          color = combinations.values[0]
          product_hash[:product_pictures] = parse_images(associations.css('image'), color)
          product_hash[:product_category_id] = parse_category(product_hash[:name], product_hash[:description])

          price_with_discount = compute_discount(product_id, price, discounts)
          combinations.each do |c_id, color|
            qty = quantities[c_id] || quantities[0] || 0
            if qty == 0
              Rails.logger.info("#{product_id} has no available qty")
            end
            article = {
              # Bags have a universal size
              size_id: 1,
              color_id: color,
              # their_color: color[1],
              sku: sku,
              price: price,
              qty: qty
            }

            unless price_with_discount.nil?
              article[:price_with_discount] = price_with_discount
            end
            product_hash[:articles] << article
          end

          add_missing_fields(product_hash)
          return product_hash
        end

        def parse_category(name, description)
          if name.include?('апка') || description.include?('апка')
            return self.women_hats_product_category_id
          elsif name.include?('шал') || description.include?('шал')
            return self.women_scarfs_product_category_id
          end
          return self.women_bags_product_category_id
        end

        def parse_qtys(quantities)
          combination_to_quantity = {}
          quantities.each do |q|
            data = fetch_xml(q['xlink:href'], AUTHORIZATION)
            comb_id = data.css('id_product_attribute').first.content.to_i
            qty = data.css('quantity').first.content.to_i
            combination_to_quantity[comb_id] = qty
          end
          return combination_to_quantity
        end

        def parse_combinations(merchant, conbinations, sku)
          combination_to_color_map = {}
          conbinations.each do |c|
            data = fetch_xml(c['xlink:href'], AUTHORIZATION)
            color = parse_color(merchant, data.css('product_option_values'), sku)
            combination_to_color_map[c.css('id').first.content.to_i] = color
          end
          return combination_to_color_map
        end

        def compute_discount(product_id, price, discounts)
          unless @sync_discounts
            return nil
          end
          discount_rules = discounts[product_id]
          price_with_discount = price
          if discount_rules.present?
            if discount_rules[:type] == 'percent'
              price_with_discount *= 1.0 - discount_rules[:amount]
            else
              price_with_discount -= discount_rules[:amount]
            end
          end

          return price_with_discount
        end

        def parse_discounts()
          discounts_data = {}
          specific_prices = fetch_xml('http://sibellebags.bg/api/specific_prices', AUTHORIZATION)
          specific_prices.css('specific_price').each do |sp|
            price_data = fetch_xml(sp['xlink:href'], AUTHORIZATION)

            # Check if the discount is valid atm
            now = Time.zone.now
            begin
              from_date = price_data.css('from').first.content.to_time
            rescue StandardError => e
              from_date = now - 1.day
            end

            begin
              to_date = price_data.css('to').first.content.to_time
            rescue StandardError => e
              to_date = now + 1.day
            end

            if now <= from_date || now >= to_date
              # The discount is not applicable now.
              next
            end

            discounts_data[price_data.css('id_product').first.content.to_i] = {
              amount: price_data.css('reduction').first.content.to_i,
              type: price_data.css('reduction_type').first.content.strip,
            }
          end
          return discounts_data
        end

        def parse_color(merchant, tag, sku)
          main_color = nil
          secondary_color = nil
          tag.css('product_option_value').each do |val|
            val_data = fetch_xml(val['xlink:href'], AUTHORIZATION)
            value_type_id = val_data.css('id_attribute_group').first.content.to_i
            unless [3, 6, 12].include?(value_type_id)
              next
            end

            color_code = val_data.css('color').first.content.strip
            # their_color = parse_translated_text_tag(val_data.css('name')) || color_code
            if color_code.blank?
              Rails.logger.error("No color code for #{value_type_id} and #{val['xlink:href']}")
              next
            end
            color_id = apply_db_mapping(merchant, 'Color', color_code)
            if color_id.blank?
              Rails.logger.error("Missing color DB mapping for merchant " \
                    "#{merchant.id} #{merchant.name} #{color_code} #{val['xlink:href']}")
              next
            end

            # curr_color = [color_id, their_color]
            curr_color = color_id
            if value_type_id == 6
              secondary_color = curr_color
            else
              if main_color.present?
                Rails.logger.warn("Main color already present! #{val['xlink:href']}")
              end
              main_color = curr_color
            end
          end

          color = main_color || secondary_color
          if color.nil?
            Rails.logger.info("Using colorful color")
            color = Color.find_by(key: 'colorful').id
            # color = [color, nil]
          end

          return color
        end

        def add_missing_fields(ph)
          # Those are fields that we failed to map or resolve using their API data
          ph[:trade_mark_id] = nil
          ph[:occasion_ids] = []
          ph[:articles].each do |a|
          end
        end

        def parse_images(tags, color_id)
          images = []
          tags.each do |tag|
            image_id = tag.css('id').first.content.strip
            source_url = "http://sibellebags.bg/#{image_id}/asd.jpg"
            images << {
              source_url: source_url,
              outfit_compatible: false,
              color_id: color_id
            }
          end
          return images
        end

        def parse_translated_text_tag(tag)
          tag.css('language#2').first.content.strip
        end

    end
  end
end


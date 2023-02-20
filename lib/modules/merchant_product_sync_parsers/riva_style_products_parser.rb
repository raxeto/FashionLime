module Modules
  module MerchantProductSyncParsers
    class RivaStyleProductsParser < BaseProductsParser
      FORBIDDEN_PRODUCTS = [
        "Gina",
        "Yvette TL140900"
      ]

      FORBIDDEN_COLORS = [
        "рубиненочервен",
        "светлосин"
      ]

      public
        def process(merchant, file_str)
          doc = parse_xml(file_str)
          no_size_id = Size.find_by_key("standart").try(:id)
          products = []
          doc.xpath("//Product").each do |product_xml|
            p = parse_product(product_xml, merchant, no_size_id)
            if p != nil
              products << p
            end
          end
          return products
        end

        def parse_product(product_xml, merchant, no_size_id)
          p = {}
          p[:name] = parse_content(product_xml, "Name")
          if FORBIDDEN_PRODUCTS.include?(p[:name])
            return nil
          end
          if p[:name].include?("зимно намаление")
            return nil
          end
          p[:description] = strip_tags(parse_content(product_xml, "Description"))

          trade_mark = parse_content(product_xml, "Manufacturer")
          if trade_mark.present?
            p[:trade_mark_id] = apply_db_mapping(merchant, "TradeMark", trade_mark)
          end

          category = parse_content(product_xml, "MainCategory").strip
          forbidden_categories = ["Лекарски чанти", "Аксесоари", "Пътни чанти и аксесоари", "Мъжки чанти", "Мъжки портфейли", "Поддръжка"]
          if forbidden_categories.include?(category)
            return nil
          end
          p[:product_category_id] = apply_db_mapping(merchant, "ProductCategory", category)
          price_with_discount = parse_content(product_xml, "Price").to_f

          pictures_hash = {}
          # The main picture is first in order
          all_pictures = parse_content(product_xml, "Image").split(',')
          main_pic_url = all_pictures[0]
          pictures_hash[main_pic_url] = {
            :source_url => escape_picture_url(main_pic_url),
            :outfit_compatible => false,
            :order_index => 1
          }

          variants = []
          product_xml.xpath("ProductVariants/variant").each do |variant|
            images = variant.at_xpath("images")
            next if images.blank?
            color = get_color_name(parse_content(variant, "name"))
            if FORBIDDEN_COLORS.include?(color)
              return nil
            end
            color_id = apply_db_mapping(merchant, "Color", color)
         
            # The main picture is first
            # Then is the first picture for each variant
            # And last are additional variant pictures
            image_ind = 0
            images.content.split(",").each do |image|
              if pictures_hash.key?(image)
                pictures_hash[image][:color_id] = color_id
              else
                order_index = (image_ind == 0 ? 2 : 3)
                pictures_hash[image] = {
                  :source_url => escape_picture_url(image),
                  :color_id => color_id,
                  :outfit_compatible => false,
                  :order_index => order_index
                }
              end
              image_ind = image_ind + 1
            end
            barcode = parse_content(variant, "barcode")
            variants << {
              :size_id => no_size_id,
              :color_id => color_id,
              :price => parse_content(variant, "price").to_f,
              :price_with_discount => price_with_discount,
              :sku => "#{parse_content(variant, 'sku')}-#{barcode}",
              :qty => parse_content(variant, "qty").to_f,
              :variant_name => parse_content(variant, "name")
            }
          end

          if pictures_hash[main_pic_url][:color_id].blank?
            Rails.logger.info("Remove picture with url #{main_pic_url} from hash because color can't be defined.")
            pictures_hash.delete(main_pic_url)
          end

          articles_hash = {}
          sign_price = 0.0
          variants.each do |v|
            sku = v[:sku]
            if articles_hash.key?(sku)
              existing_variant = articles_hash[sku]
              sign_price = [sign_price, (existing_variant[:price] - v[:price]).abs].max
              if existing_variant[:price] > v[:price]
                # Set no sign price
                existing_variant[:price] = v[:price]
              end
            else
              articles_hash[sku] = v
            end
          end
          if sign_price > 0.0
            p[:description] =  "*** ЗА ТОЗИ ПРОДУКТ МОЖЕТЕ ДА ПОРЪЧАТЕ ГРАВИРАНЕ НА НАДПИС, например вашите инициали или вашето име! Ако желаете да поръчате надпис, ни напишете в забележката на поръчката какъв да бъде той. Гравирането е на допълнителна цена от #{num_to_currency(sign_price)} #{p[:description]}"
            p[:picture_watermark_url] = "/watermarks/engraving-wm.png"
          end

          p[:articles] = articles_hash.values
          p[:product_pictures] = pictures_hash.values.sort_by { |p| p[:order_index] }
          return p
        end

        def get_color_name(variant_name)
          color_word = "цвят:"
          color_word_start = variant_name.index(color_word)
          if color_word_start.nil?
            return nil
          end

          engraving_word = "Желаете ли гравиране"
          engraving_word_start = variant_name.index(engraving_word)
          if engraving_word_start.present?
            end_of_color = engraving_word_start - 1
            variant_name = variant_name[0..end_of_color]
            variant_name = variant_name.strip.chomp("-")
          end

          color_start = color_word_start + color_word.length
          variant_name[color_start..-1].strip
        end

        def escape_picture_url(image)
          image.gsub("[", "%5B").gsub("]", "%5D")
        end
    end
  end
end


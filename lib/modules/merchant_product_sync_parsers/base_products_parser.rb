module Modules
  module MerchantProductSyncParsers
    class BaseProductsParser

      include ActionView::Helpers::SanitizeHelper

      public

        attr_accessor :error_occurred

        # Configuration attributes that define specific rules for the sync
        attr_accessor :sync_discounts
        attr_accessor :check_matching_by_name

        def initialize
          # Set up the default values for attributes here.
          @error_occurred = false
          @sync_discounts = true
          @check_matching_by_name = false
          super
        end

        def process(merchant, file_str)
          begin
            return self.parse_internal(merchant, file_str)
          rescue StandardError => e
            log_error("Failed parsing the file: #{e} #{e.backtrace.join("\n")}")
            return nil
          end
        end

        def fetch_content(scrape_url, http_authorization=nil)
          uri = URI(scrape_url)
          req = Net::HTTP::Get.new(uri)
          if http_authorization.present?
            req['Authorization'] = "Basic #{http_authorization}"
          end

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') {|http|
            http.read_timeout = 300
            http.request(req)
          }
          return res.body
        end

        protected

        def log_error(error_msg)
          Rails.logger.error(error_msg)
          @error_occurred = true
        end

        def fetch_xml(scrape_url, http_authorization=nil)
          content = fetch_content(scrape_url, http_authorization)
          return parse_xml(content)
        end

        def parse_internal(file_str)
          raise "This base method should not be called!"
        end

        def parse_xml(xml_str)
          begin
            return Nokogiri::XML::Document.parse(xml_str)
          rescue StandardError => e
            log_error("Failed parsing the XML string: #{e}")
            return nil
          end
        end

        def parse_json(json_str)
          begin
            return JSON.parse(json_str)
          rescue StandardError => e
            log_error("Failed parsing the JSON string: #{e}")
            return nil
          end
        end

        def parse_content(element, search_tag)
          tag = element.at_xpath(search_tag)
          if tag.nil?
            log_error("Failed to parse XML content. Search tag is #{search_tag}.")
            return nil
          end
          tag.content
        end

        def apply_db_mapping(merchant, type, input_value)
          apply_db_mapping_with_conditional_error(merchant, type, input_value, true)
        end

        def apply_db_mapping_with_conditional_error(merchant, type, input_value, is_error_if_not_found)
          mapping = MerchantProductApiMapping.where(merchant_id: merchant.id, object_type: type, input_value: input_value).first
          if mapping.blank?
            if is_error_if_not_found
              log_error("No mapping found for type #{type}, value #{input_value} and merchant #{merchant.name}")
            end
            return nil
          end
          return mapping.object_id
        end

        def is_url_valid(url_path)
          url = URI.parse(url_path)
          req = Net::HTTP.new(url.host, url.port)
          req.use_ssl = url.scheme == 'https'
          res = req.request_head(url.path)
          res.code == "200"
        end

    end
  end
end


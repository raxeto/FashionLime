module Modules
  module DelayedJobs
    class EpayCodeFetcher

      EpayCodeFetcherJob = Struct.new(:merchant_epay_info_id, :merchant_order_number, :amount) do
        def max_attempts
          10
        end

        def reschedule_at(current_time, attempts)
          current_time + (2 + attempts ** 2).seconds
        end

        def failure(job)
          merchant_order = MerchantOrder.find_by(number: merchant_order_number)
          merchant_order.update_attribute(:payment_code, Conf.payments.epay_failed_code)
          Rails.logger.error("Failed to get payment code from ePay in #{max_attempts()} attempts." \
                " ePay info ID: #{merchant_epay_info_id}" \
                " Merchant order ID: #{merchant_order.id}" \
                " amount: #{amount}")
        end

        def perform
          info = MerchantEpayInfo.find_by_id(merchant_epay_info_id)
          if info.blank?
            Rails.logger.error("Trying to update a non existing epay info record! " \
                "ID: #{merchant_epay_info_id} order number: #{merchant_order_number}" \
                " amount: #{amount}")
            return
          end

          merchant_order = MerchantOrder.find_by(number: merchant_order_number)
          if merchant_order.blank?
            Rails.logger.error("Merchant order number #{merchant_order_number} is invalid! #{merchant_epay_info_id}, #{amount}")
            return
          end

          if merchant_order.payment_code.present?
            Rails.logger.error("Merchant order #{merchant_order.id} already has a payment_code set!")
            return
          end

          # In case we can't resolve the code, we will set it to the NOCODE value.
          # It is important that this job runs once and only once and always sets the
          # code to something different than nil.
          Rails.logger.info("getting code for #{merchant_order_number} #{amount}")
          code = info.request_payment_code(merchant_order_number, amount)
          if code.present? && code.starts_with?('IDN=')
            Rails.logger.info("Succeeded getting code #{code}")
            merchant_order.update_attribute(:payment_code, code[4..-1])
          elsif code.present?
            Rails.logger.error("Got error from ePay: #{process_failed_code(code)}")
            merchant_order.update_attribute(:payment_code, Conf.payments.epay_failed_code)
          else
            raise "Failed getting a response from Epay. Will retry soon."
          end
        end

        def process_failed_code(code)
          begin
            code.force_encoding("cp1251").encode("utf-8")
          rescue Encoding::UndefinedConversionError
            Rails.logger.error("Failed to convert the error code to UTF-8")
            code.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: '?'})
          end
        end
      end

      class << self
        def get(merchant_epay_info_id, merchant_order_number, amount)
          Delayed::Job.enqueue EpayCodeFetcherJob.new(merchant_epay_info_id, merchant_order_number, amount)
        end
      end
    end
  end
end

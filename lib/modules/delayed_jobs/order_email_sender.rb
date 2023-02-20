module Modules
  module DelayedJobs
    class OrderEmailSender

      OrderEmailSenderJob = Struct.new(:order_id) do
        def perform
          order = Order.find_by(id: order_id)
          if order.blank?
            Rails.logger.error("Trying to send an email for a non-existing order with id #{order_id}")
            return
          end

          if order.user_email.blank?
            Rails.logger.error("Order ID: #{order.id} has no email set!")
            raise "Order ID: #{order.id} has no email set!"
          end

          if !order.is_ready_for_payment?
            Rails.logger.warn("Order ID:#{order.id} is still waiting on some payment codes.")
            raise "Order ID:#{order.id} is still waiting on some payment codes."
          end

          if !order.is_payment_info_valid?
            Rails.logger.warn("Order ID:#{order.id} has invalid payment info!")
            AdminMailer.new_failed_order_payment(order_id).deliver_now
          end

          order.merchant_orders.each do |mo|
            OrderMailer.merchant_new(mo).deliver_now
          end

          OrderMailer.user_new(order).deliver_now
          Rails.logger.info("Email for #{order_id} to #{order.user_email} sent successfully")
        end

        def max_attempts
          10
        end

        def reschedule_at(current_time, attempts)
          current_time + (5 + attempts ** 2).seconds
        end

      end

      class << self
        def send(order_id)
          Delayed::Job.enqueue OrderEmailSenderJob.new(order_id)
        end
      end
    end
  end
end

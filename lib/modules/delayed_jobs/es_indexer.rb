module Modules
  module DelayedJobs
    class EsIndexer

      class << self
        def schedule(operation, record)
          if record.nil?
            Rails.logger.error 'Trying to update a nil record'
            return
          end

          # For now only skip Product es refresh
          # Outfits are refreshed only if price or quantity is changed to or from zero.
          # But be aware for the future - monitor delayed job table from time to time
          if record.is_a?(Product) && Modules::ProductMassUpdate.is_in_progress(record)
            Rails.logger.info("Skipping ES indexing because of merchant sync. Product ID #{record.id}. Operation #{operation}.")
            return
          end

          if Rails.env.production? || Rails.env.staging?
            # Perform the ES updates asynchronously.
            self.perform_async(operation, record.id, record.class.name)
          else
            # Perform the updates right away when in development.
            self.perform_async_without_delay(operation, record.id, record.class.name)
          end
        end

        def perform_async(operation, record_id, class_name)
          Rails.logger.info("performing #{operation} on #{class_name} ID##{record_id}")
          c = class_name.constantize
          if c.blank?
            raise "Unknown class #{class_name}"
          end

          if !c.respond_to?('__elasticsearch__')
            raise "#{class_name} doesn't have a valid index in Elasticsearch"
          end

          record = c.find_by(id: record_id.to_i)
          if record.present?
            record.__elasticsearch__.send(operation)
          else
            begin
              Elasticsearch::Model.client.delete index: class_name.downcase.pluralize, type: class_name.downcase, id: record_id
            rescue => ex
              puts("Delete failed: #{ex}")
            end
          end
        end
        handle_asynchronously :perform_async
      end

    end
  end
end
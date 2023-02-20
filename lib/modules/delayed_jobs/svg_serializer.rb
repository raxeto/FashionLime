module Modules
  module DelayedJobs
    class SvgSerializer

      SvgSerializerJob = Struct.new(:outfit_id, :server_url, :scrape_url) do
        def perform
          outfit = Outfit.find_by(id: outfit_id)
          if outfit.blank?
            Rails.logger.error("Trying to serialize an SVG for a non-existing outfit with id #{outfit_id}")
            return
          end
          outfit.save_svg_to_png_picture(server_url, outfit.serialized_svg, scrape_url)
          outfit.update_attributes(:serialized_svg => nil)
        end

        def max_attempts
          10
        end

        def reschedule_at(current_time, attempts)
          current_time + (attempts ** 2).seconds
        end

        def failure(job)
          AdminMailer.new_failed_svg_serialization(outfit_id).deliver_now
        end

      end

      class << self
        def do(outfit_id, server_url, serialized_svg, scrape_url)
          outfit = Outfit.find_by(id: outfit_id)
          if Rails.env.production? || Rails.env.staging?
            if outfit.update_attributes(:serialized_svg => serialized_svg)
              Delayed::Job.enqueue SvgSerializerJob.new(outfit_id, server_url, scrape_url)
            else
              Rails.logger.error("Saving serialized_svg for outfit with ID #{outfit.id} failed.")
            end
          else
            outfit.save_svg_to_png_picture(server_url, serialized_svg, scrape_url)
          end
        end
      end
    end
  end
end

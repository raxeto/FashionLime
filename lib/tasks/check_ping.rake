require 'net/http'
require 'net/https'
require 'uri'

namespace :check do
  desc "Performs a single ping request to our production server and sends emails to the admins if the ping fails"
  task :ping => "setup:logger" do
    is_up?
  end

  def is_up?
    now = Time.now
    parsed_url = URI.parse("https://fashionlime.bg/ping")

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    http.read_timeout = 10

    request = Net::HTTP::Get.new(parsed_url.to_s)

    begin
      response = http.request(request)
    rescue => e
      Rails.logger.error("Failed to ping https://fashionlime.bg/ping! #{e}")
      return false
    end

    result = response.body.try(:strip)
    if result != "OK"
      Rails.logger.error("Failed to ping https://fashionlime.bg/ping #{result}")
      return false
    end
    response_time = Time.now - now
    Rails.logger.info("Success. It took #{response_time.seconds}")

    # Consider the ping a success IFF it took less than 5 seconds to execute.
    return response_time < 5
  end
end

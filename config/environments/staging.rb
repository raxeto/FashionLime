# For elasticsearch debug info.
require 'elasticsearch/rails/instrumentation'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # config.action_mailer.asset_host = "http address with port here"
  config.action_mailer.perform_deliveries = false
  config.action_mailer.default_url_options = { host: 'http address with port here' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {
    location: '/usr/sbin/sendmail',
    arguments: '-i -t'
  }

  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.assets.compile = false

  config.client_lib = {
      default_url_options: {
          host: '0.0.0.0:3000'
      }
  }

  # Compress JavaScripts and CSS
  class NoCompression
    def compress(string)
        # do nothing
         string
    end
  end

  config.assets.compress = true
  config.assets.gzip = true
  config.assets.js_compressor = NoCompression.new
  config.assets.css_compressor = NoCompression.new

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Paperclip configuration.
  Paperclip.options[:command_path] = '/usr/local/bin/'

  config.app_url = 'http address with port here'

  # Paperclip settings.
  config.paperclip_defaults = {
    url: "/system/:class/:id/:attachment/:style.:extension"
  }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.payments = {
    epay_url: 'https://demo.epay.bg'
  }
end

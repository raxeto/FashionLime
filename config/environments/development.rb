# For elasticsearch debug info.
require 'elasticsearch/rails/instrumentation'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.cache_store = :dalli_store, 'localhost:11211',
      { :namespace => 'FashionLime', :expires_in => 1.week, :compress => true }

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.asset_host = "http://localhost:3000"
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {
    location: '/usr/sbin/sendmail',
    arguments: '-i -t'
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  config.assets.quiet = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Paperclip configuration.
  Paperclip.options[:command_path] = '/opt/local/bin/'

  config.app_url = 'http://localhost:3000'

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

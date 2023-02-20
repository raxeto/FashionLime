require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dressme
  class Application < Rails::Application

    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.paths << "#{Rails}/vendor/assets/stylesheets"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    config.time_zone = 'Sofia'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.site_name = "FashionLime"

    # 404, 422 and 500 pages to be routed from Rails router (routes.rb)
    config.exceptions_app = self.routes

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(#{config.root}/lib)
    #config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.i18n.default_locale = :bg
    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]

    config.active_job.queue_adapter = :delayed_job

    config.client_lib = {
        default_url_options: {
            host: 'localhost:3000'
        }
    }
  end
end

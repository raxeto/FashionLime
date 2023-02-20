source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'

gem 'sprockets-rails', '~> 3.1.0'

# Use MySQL as the database for Active Record
# NB: There is a newer version, but there is an issue with it and rails 4!
gem 'mysql2', '~> 0.3.18'

# ActiveRecord sessions store
gem 'activerecord-session_store'

# Use lesscss for CSS
gem 'less-rails', '~> 2.8.0'
gem 'twitter-bootstrap-rails', '~> 3.2.0'

# Update this on a regular basis.
gem 'tzinfo-data', '~> 1.2015.7'

# TODO Joro: gems filtered and checked till here

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.7.2'

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.2'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.0.5'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5.3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.3.2'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'devise', '~> 3.5'

# Attachments
gem 'paperclip', '~> 4.3'

# Helper for enum translations
gem 'enum_help', '~> 0.0.14'

# Helper for dealing with business days
gem 'business_time', '~> 0.7.4'

# For the product images
gem 'smoothproducts_rails', '~> 0.0.1'

# Images manipulation
gem 'rmagick', '~> 2.15.4'

# XML parser helper library
gem 'nokogiri'

gem 'sass-rails', '~> 5.0'

# For product search
gem 'elasticsearch-model', '~> 0.1.8'
gem 'elasticsearch-rails', '~> 0.1.8'

# Google api integration
gem 'google-api-client', '~> 0.8.6'

# Bootstrap forms helper
gem 'bootstrap_form', '~> 2.3'

# Breadcrumbs menu helper
gem 'breadcrumbs_on_rails', '~> 2.3.1'

# Excel, Open office, CSV import
gem 'roo', '~> 2.3.1'

# Sitemaps
gem 'sitemap_generator', '~> 5.1'

# Asynchronous Jobs
gem 'delayed_job', '~> 4.1'
gem 'delayed_job_active_record', '~> 4.1'

# https://github.com/collectiveidea/delayed_job/tree/v4.1.2#running-jobs
gem 'daemons' # Used so that delayed job is executed as a service

# Typeahead a.k.a autocomplete
gem 'twitter-typeahead-rails', '~> 0.11.1'

# Inlining CSS styles in HTML emails
gem 'roadie-rails', '~> 1.1', '>= 1.1.1'

# Bad words filter
gem 'obscenity', '~> 1.0.2'

# To encrypt sensitive information in the database
gem 'attr_encrypted', '~> 3.0'

# HTML select element plugin
gem 'select2-rails', '~> 4.0.3'

# Cron job scheduling
gem 'whenever', '~> 0.9.7'

# Java Script templates
gem 'handlebars_assets', '~> 0.23.1'

# For standard server side pagination
gem 'kaminari', '~> 1.0.1'

gem 'rubyzip', '~> 1.2.0'

# Enables using memcached as a cache store
gem 'dalli', '~> 2.7.6'

group :production do
  # Our production setup will run on Puma + nginx
  gem 'puma', '~> 3.6'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rbenv', '~> 2.1.0rvm'
  # gem 'capistrano-rvm'
  gem 'capistrano3-puma'
  gem 'capistrano3-delayed-job', '~> 1.0'
end


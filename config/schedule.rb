# http://github.com/javan/whenever

set :output, {:error => '~/web/shared/log/cron.error.log', :standard => '~/web/shared/log/cron.log'}
set :args_str, " "

# I had to add "~/.rbenv/bin/rbenv exec", because we couldn't resolve bundle otherwise
job_type :rake,    "cd :path && :environment_variable=:environment ~/.rbenv/bin/rbenv exec bundle exec rake :task:args_str --silent :output"


if @environment == 'production'
  # Every minute

  every 1.minute do
    rake "check:nginx_logs"
  end

  every 6.minutes do
    rake "refresh_products_cache"
  end

  every '2,8,14,20,26,32,38,44,50,56 * * * *' do
    rake "refresh_outfits_cache"
  end

  every 10.minutes do
    rake "check:production_logs"
  end

  # Daily

  every 1.day, :at => '07:05 am' do
    rake "product_catalog:refresh_file"
  end

  #every 1.day, :at => '01:30 am' do
  #  command "~/.rbenv/bin/rbenv exec backup perform -t backup_database_and_images --root-path ~/web/shared/config/backup"
  #end

  #every 1.day, :at => '07:00 am' do
  #  rake "sitemap:refresh"
  #end

  every 1.day, :at => '05:00 am' do
    rake "clean:old_request_stats"
  end

  every 1.day, :at => '05:10 am' do
    rake "clean:old_guests"
  end

  every 1.day, :at => '05:20 am' do
    rake "clean:old_sessions"
  end

  #require File.expand_path(File.dirname(__FILE__) + "/environment.rb")
  #MerchantProductsSyncTask.all.each do |task|
  #  every 1.day, :at => task.cron_daily_update_time do
  #    rake "refresh_merchant_products", args_str: "[#{task.id}]"
  #  end
  #end

end

if @environment == 'staging'
  every 1.minute do
    rake "check:ping", environment: :staging
  end
end
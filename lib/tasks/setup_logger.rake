namespace :setup do
  desc "Setup the logger for the rake tasks that will be executed next. Don't run this
  task directly - use it as a dependency."
  task :logger do
    logger           = Logger.new(STDOUT)
    logger.level     = Logger::INFO
    Rails.logger     = logger
  end
end

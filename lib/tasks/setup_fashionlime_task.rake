namespace :setup do
  desc "Setup the environment for the rake tasks that will be executed next. Don't run this
  task directly - use it as a dependency for ALL rake tasks."
  task :fashionlime => [:environment, "setup:logger"] do
    Rails.logger.info "Environment loaded successfully."
  end
end

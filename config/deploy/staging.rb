set :branch, "master"
set :rails_env, "staging"
set :puma_env, "staging"

# For multi server configuration:
# role :app, %w{0.0.0.0 0.0.0.0}, user: 'deploy'

# When we switch to the new staging:
# role :app, %w{0.0.0.0}, user: 'deploy'
# role :web, %w{0.0.0.0}, user: 'deploy'
# role :db, %w{0.0.0.0}, user: 'deploy'
# role :background, %w{0.0.0.0}, user: 'deploy'

# Current config, until we go live and all the links we've given to merchants are no longer needed
role :app, %w{0.0.0.0}, user: 'deploy'
role :web, %w{0.0.0.0}, user: 'deploy'
role :db, %w{0.0.0.0}, user: 'deploy'
role :background, %w{0.0.0.0}, user: 'deploy'

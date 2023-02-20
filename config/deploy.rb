# config valid only for current version of Capistrano
lock '3.7.2'

set :user, "deploy"
set :deploy_to, "/home/#{fetch(:user)}/web"

set :application, 'DressMe'
set :repo_url, 'git@0.0.0.0:/opt/git/project.git'

set :use_sudo, false
set :deploy_via, :copy # change this to remove_cache once copy starts working

set :ssh_options, { :forward_agent => true } # set :port to something != 22
set :keep_releases, 5

set :conditionally_migrate, true
set :keep_assets, 2

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'public/system', 'tmp/sockets')#, 'vendor/bundle', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

set :puma_init_active_record, true

set :delayed_job_roles, [:background]
set :delayed_job_pid_dir, '/tmp'

set :whenever_roles, [:background]

set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value


namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :refresh_sitemap do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'sitemap:refresh:no_ping'
        end
      end
    end
  end

  task :reindex_es do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'reindex_es'
        end
      end
    end
  end

  # Example usage:
  # cap production deploy:run_rake task="check:nginx_logs"
  task :run_rake do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, ENV['task']
        end
      end
    end
  end

end

after "deploy", "deploy:restart"
after "deploy", "deploy:cleanup"
after "deploy", "deploy:refresh_sitemap"
after "deploy", "deploy:reindex_es" unless ENV['SKIP_FULL_ES_REINDEX']


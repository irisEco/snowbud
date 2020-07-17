# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "demo_api"
set :repo_url, "git@gitlab.deercal.com:yw/demo.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rvm_ruby_version, '2.6.5'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/yw/apps/#{fetch(:application)}_#{fetch(:stage)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
set :linked_files, %w{
  config/database.yml config/nginx.conf config/puma.rb
  config/services.yml
  config/app_settings/ali.yml config/app_settings/sms.yml
}

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w{
  log tmp/pids tmp/sockets
}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { RACK_ENV: fetch(:rack_env) || fetch(:stage) }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# Skip migration if files in db/migrate were not modified
set :conditionally_migrate, true

set :sidekiq_roles, :sidekiq
set :sidekiq_config, "#{current_path}/config/sidekiq.yml"
set :sidekiq_require, "#{current_path}/config/application.rb"
set :sidekiq_monit_conf_dir, '/etc/monit.d'
set :sidekiq_monit_conf_file, "sidekiq_#{fetch(:application)}_#{fetch(:stage)}.conf"
set :sidekiq_service_name, "sidekiq_#{fetch(:application)}_#{fetch(:stage)}"
set :sidekiq_default_hooks, false
set :sidekiq_tag, "#{fetch(:application)}_#{fetch(:stage)}"

set :puma_preload_app, true
set :puma_init_active_record, true
set :puma_monit_conf_dir, "/etc/monit.d/puma_#{fetch(:application)}_#{fetch(:stage)}.conf"
set :puma_control_app, true
set :puma_conf, "#{shared_path}/config/puma.rb"
set :puma_workers, 2
set :puma_daemonize, true
set :puma_threads, [0, 16]
set :puma_tag, "#{fetch(:application)}"

SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq"
SSHKit.config.command_map[:sidekiqctl] = "bundle exec sidekiqctl"

namespace :deploy do
  after 'deploy:publishing', 'deploy:restart'
  task :restart do
    invoke 'puma:phased-restart'
  end

  before :starting, :check_sidekiq_hooks do
    after 'deploy:published', 'sidekiq:monit:restart'
  end

  desc "upload setup_config for application; 'cap staging deploy:upload_config'"
  task :upload_config do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "deploy:check:make_linked_dirs"

      fetch(:linked_files).each do |file_path|
        unless test "[ -f #{shared_path}/#{file_path} ]"
          upload!("#{file_path}", "#{shared_path}/#{file_path}", via: :scp)
        end
      end
    end
  end
end

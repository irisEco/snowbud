load File.expand_path("../set_rack_env.rake", __FILE__)

namespace :deploy do
  desc 'Runs rake db:migrate'
  task :migrate => [:set_rack_env] do
    on roles(:db) do
      conditionally_migrate = fetch(:conditionally_migrate)
      info '[deploy:migrate] Checking changes in db' if conditionally_migrate
      if conditionally_migrate && test(:diff, "-qr #{release_path}/db #{current_path}/db")
        info '[deploy:migrate] Skip `deploy:migrate` (nothing changed in db)'
      else
        info '[deploy:migrate] Run `rake db:migrate`'
        # NOTE: We access instance variable since the accessor was only added recently. Once capistrano-rails depends on rake 11+, we can revert the following line
        invoke :'deploy:migrating' unless Rake::Task[:'deploy:migrating'].instance_variable_get(:@already_invoked)
      end
    end
  end

  desc 'Runs rake db:migrate'
  task migrating: [:set_rack_env] do
    on roles(:db) do
      within release_path do
        with RACK_ENV: fetch(:rack_env) do
          execute :rake, 'db:migrate'
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:migrate'
end

namespace :load do
  task :defaults do
    # Add racksh to RVM, Rbenv and Chruby bins
    %i[rvm_map_bins rbenv_map_bins chruby_map_bins].each do |bins_var|
      bins = fetch(bins_var, [])
      set bins_var, bins.push('racksh') unless bins.include?('racksh')
    end

    # Default values
    set :console_env,   -> { fetch(:rack_env, fetch(:stage, 'production')) }
    set :console_user,  -> { fetch(:app_user, nil) }
    set :console_role,  :app
    set :console_shell, nil
  end
end

namespace :rack do
  desc "open rack console like rails console"
  task :console do
    run_interactively primary(fetch(:console_role)), shell: fetch(:console_shell) do
      within current_path do
        as user: fetch(:console_user) do
          execute(:bundle, :exec, "'RACK_ENV=#{fetch(:console_env)} racksh'")
        end
      end
    end
  end
end

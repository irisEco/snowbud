namespace :deploy do
  task :set_rack_env do
    set :RACK_ENV, (fetch(:rack_env) || fetch(:stage))
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'deploy:set_rack_env'
end

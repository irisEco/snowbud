require_relative 'environment'
require 'sidekiq/web'
require 'sidekiq/cron/web'

ApplicationServer = Rack::Builder.new {
  map '/' do
    run lambda { |env|
      [
        200,
        {
          'Content-Type'  => 'text/html',
          'Cache-Control' => 'public, max-age=86400'
        },
        File.open('public/swagger-ui/index.html', File::RDONLY)
      ]
    }
  end

  map '/api/common' do
    run Common::V1::Root
  end

  map '/api/admin' do
    run Admin::V1::Root
  end

  map '/api/client' do
    run Client::V1::Root
  end

  map '/api/manager' do
    run Manager::V1::Root
  end

  map '/sidekiq' do
    Sidekiq::Web.set :session_secret, SERVICES_CONFIG["secret_token"]

    use Rack::Auth::Basic, 'Secret Area' do |username, password|
      username == "sidekiqadmin" && password == SERVICES_CONFIG.dig("sidekiq", "web_auth_password")
    end if Application.config.env.production? || Application.config.env.staging?

    run Sidekiq::Web
  end
}

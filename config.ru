require_relative 'config/application'
require 'rack/cors'

# Clean up database connections after every request (required)
use OTR::ActiveRecord::ConnectionManagement

use RequestStore::Middleware

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, expose: ['x-page', 'x-per-page', 'x-total'], methods: [ :get, :post, :put, :delete, :options ]
  end
end

use Rack::Static,
    root: File.expand_path('../public/swagger-ui', __FILE__),
    urls: ["/css", "/images", "/js"],
    index: 'index.html'

run ApplicationServer

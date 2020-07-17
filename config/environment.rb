# $:.unshift File.dirname(__FILE__)

puts "=====start up env:#{ENV['RACK_ENV']}"
env = (ENV['RACK_ENV'] || :development)

require 'rubygems'
require 'bundler'
require 'bundler/setup'

Bundler.require(:default, env.to_sym)
require 'erb'
require 'action_mailer'
require 'api-pagination'

module Application
  include ActiveSupport::Configurable

  def self.relative_load_paths
    %w[
      app/settings
      app/workers
      app/observers
      lib
      vender
    ]
  end

  def self.eager_load!
    ActiveRecord.eager_load!

    relative_load_paths.each do |load_path|
      matcher = /\A#{Regexp.escape(load_path.to_s)}\/(.*)\.rb\Z/
      Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end
    end

    loader = Zeitwerk::Loader.new

    loader.push_dir(Application.root.join("app/services"))
    loader.push_dir(Application.root.join("app/validators"))
    loader.push_dir(Application.root.join("app/api"))
    # 按照models文件夹顺序添加
    # loader.push_dir(Application.root.join("app/models/addresses"))
    loader.push_dir(Application.root.join("app/models"))
    loader.push_dir(Application.root.join("app/mailers"))
    loader.push_dir(Application.root.join("app/views"))
    loader.setup
    loader.eager_load
  end

  def self.load_tasks
    Dir['lib/tasks/**/*.rake'].each { |f| load f }
  end

  def self.logger
    @logger ||= Logger.new("#{Application.root}/log/#{Application.config.env}.log")
  end

  # 针对第三方请求的日志记录
  def self.vender_logger
    @vender_logger ||= Logger.new("#{Application.root}/log/vender_#{Application.config.env}.log", "weekly")
  end

  # 管理端日志
  def self.manager_logger
    @manager_logger ||= Logger.new("#{Application.root}/log/manager_#{Application.config.env}.log", "weekly")
  end

  # 客户端日志
  def self.client_logger
    @client_logger ||= Logger.new("#{Application.root}/log/client_#{Application.config.env}.log", "weekly")
  end

  # 超管端日志
  def self.admin_logger
    @client_logger ||= Logger.new("#{Application.root}/log/admin_#{Application.config.env}.log", "weekly")
  end

  def self.root
    Pathname.new(File.expand_path("../", __dir__))
  end
end

Application.configure do |config|
  config.root      = Pathname.new(File.dirname(__FILE__))
  config.env       = ActiveSupport::StringInquirer.new(env.to_s)
  config.time_zone = "Beijing"
end

# 时区设置
Time.zone_default = Time.find_zone!(Application.config.time_zone)
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc

# 数据库连接设置
database_file = "#{Application.config.root}/database.yml"
OTR::ActiveRecord.configure_from_file! database_file

# 邮件配置
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.view_paths = "#{Application.root}/app/views"

ActiveSupport::Dependencies.autoload_paths += Application.relative_load_paths

# I18n
I18n.load_path += Dir[File.join(Application.config.root, 'locales', '**', '*.{rb,yml}')]
I18n.locale = :'zh-CN'
I18n.default_locale = :'zh-CN'
I18n.backend.load_translations

SERVICES_CONFIG = OpenStruct.new(YAML.load_file("#{Application.config.root}/services.yml")[env.to_s])

specific_environment = "#{Application.config.root}/environments/#{Application.config.env}.rb"
require specific_environment if File.exists?(specific_environment)

Dir[File.join(Application.config.root, 'initializers', '**', '*.rb')].each { |f| require f }

module Manager::V1::Helpers::EntityHelper
  extend Grape::API::Helpers

  Grape::Entity.format_with :local do |date|
    I18n.l(date, default: nil)
  end

  Grape::Entity.format_with :local_normal do |date|
    I18n.l(date, format: :normal, default: nil)
  end

  Grape::Entity.format_with :local_date do |date|
    I18n.l(date, format: :date, default: nil)
  end
end

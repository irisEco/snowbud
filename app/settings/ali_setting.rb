# 阿里云相关接口配置文件
class AliSetting < Settingslogic

  source "#{Application.config.root}/app_settings/ali.yml"
  namespace Application.config.env

end

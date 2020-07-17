# 异常配置文件
class ExceptionSetting < Settingslogic

  source "#{Application.config.root}/settings/exception.yml"
  namespace Application.config.env
end

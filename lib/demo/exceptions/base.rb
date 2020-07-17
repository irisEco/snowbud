module Demo::Exceptions
  class Base < StandardError
    attr_accessor :code

    def initialize(message, code)
      @code = code
      super(message)
    end
  end

  # 业务级别的错误动态定义
  ExceptionSetting.project.each do |k, val|
    klass = Class.new(Base) do
      define_method :initialize do |_msg = nil|
        code = "#{val["code"]}"
        _msg ||= "#{val["message"]}"
        super(_msg, code)
      end
    end
    Interview::Exceptions.const_set(k, klass)
  end
end

module Common
  module V1
    module Validators
      class MobileNumber < Grape::Validations::Base
        def validate_param!(attr_name, params)
          value = params[attr_name]
          return true if value =~ /\A^1\d{10}\z/
          raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: '不符合手机号码格式'
        end
      end
    end
  end
end

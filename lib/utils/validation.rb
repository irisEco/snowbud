# frozen_string_literal: true

module Utils
  class Validation
    class << self
      # 手机号格式判断
      def mobile?(str)
        return true if str.present? && str =~ /\A(13\d|14\d|15\d|16\d|17\d|18\d|19\d)\d{8}\z/i
      end

      # 身份证格式判断
      def id_card?(str)
        return str.length == 18
      end

      # 身份证是否满十八岁
      def age?(str)
        birthday = str[6..13].to_date
        age = Date.today.year - birthday.year
        age -= 1 if Date.today < birthday + age.years #for days before birthday
        return age >= 16
      end
    end
  end
end

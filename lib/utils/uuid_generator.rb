# frozen_string_literal: true

module Utils
  class UuidGenerator

    CHARSETS = {
      upcase_and_num: ('A'..'Z').to_a + (0..9).to_a
    }

    class << self

      def generate_code(prefix = nil, num = 4, charset = :upcase_and_num)
        "#{prefix}#{Time.new.strftime("%Y%m%d%H%M%S")}#{key_chars(charset).sample(num.to_i).join}"
      end

      def generate_ipay_req_id(record_id, prefix = nil)
        "#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10000).to_s.rjust(4, "0")}-#{prefix}-#{record_id}"
      end

      private

      def key_chars(charset)
        CHARSETS[charset]
      end

    end

  end
end

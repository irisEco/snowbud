# frozen_string_literal: true

module Utils
  class Money

    Money = {
      figure: '零壹贰叁肆伍陆柒捌玖',
      minor_units: '拾佰仟',
      major_units: '万亿',
      decimal_units: '角分',
      unit: '元',
      round_unit: '整',
      minus_unit: '负'
    }

    attr_accessor :money

    def initialize
      @money = money_trans(Money.dup)
    end

    def to_zh(num)
      result = []

      b_num = (num.is_a? BigDecimal) ? num : BigDecimal(num.to_s)
      # 金额只保留前两位小数
      b_num = b_num.truncate(2)

      money_zero = money[:figure][0]
      return "#{money_zero}#{money[:unit]}#{money[:round_unit]}" if b_num.zero?

      temp = b_num.abs.divmod(1)
      round_section = temp[0].to_s('F').to_i
      decimal_section = temp[1].to_s('F').split('.')[1]

      result_round_section = round_section_zh(round_section)
      result << result_round_section unless result_round_section.empty?
      result << money[:unit] unless result_round_section.empty?

      unless temp[1].zero?
        result_decimal_section = decimal_section_zh(decimal_section)
        result_decimal_section.gsub!(/(?<=\A|["#{money_zero}"])["#{money_zero}"]+/, '') if result.empty?
        result << result_decimal_section
      end

      result << money[:round_unit] if BigDecimal(decimal_section).zero?
      result.unshift(money[:minus_unit]) if b_num < 0 && result
      result.join
    end

    private

    def money_trans(m)
      trans = m
      trans[:figure] = m[:figure].strip.chars
      trans[:minor_units] = m[:minor_units].strip.chars.unshift(nil)
      trans[:major_units] = m[:major_units].strip.chars.unshift(nil)
      trans[:decimal_units] = m[:decimal_units].strip.chars

      trans
    end

    def round_section_zh(num)
      result = []
      unit_index = -1

      figure_type = money[:figure]
      unit_type = money[:minor_units]

      num.to_s.chars.map(&:to_i).reverse.each_slice(4) do |figures|
        section = figures.zip(unit_type).map do |figure, unit|
          figure ||= 0
          if figure.zero?
            figure_type[0]
          else
            "#{figure_type[figure]}#{unit}"
          end
        end.reverse.join

        unit_index += 1

        section.gsub!(/["#{figure_type[0]}"]+\z/x, '')

        next if section.empty?

        result << round_section_unit(unit_index)
        result << section
      end

      result.reverse.join.gsub(/(?<=\A|["#{figure_type[0]}"])["#{figure_type[0]}"]+/, '')
    end

    def round_section_unit(unit_index)
      major_units = money[:major_units]
      major_units[1] * (unit_index % 2) + major_units[2] * (unit_index / 2)
    end

    def decimal_section_zh(num)
      figure_type = money[:figure]
      figures = num.chars.map(&:to_i).zip(money[:decimal_units])

      figures.map do |figure, unit|
        if figure.zero?
          figure_type[0]
        else
          "#{figure_type[figure]}#{unit}"
        end
      end.join
    end

  end
end

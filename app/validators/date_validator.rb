class DateValidator < ActiveModel::EachValidator

  # 日期合法的格式为yyyy-mm-dd
  def validate_each(record, attribute, value)
    _section = value.to_s.split('-')
    _date = Date.civil(_section[0].to_i, _section[1].to_i, _section[2].to_i) rescue nil
    if _section.empty? || _date.nil?
      default_message = record.errors.generate_message(attribute, :invalid)
      record.errors[attribute] << (options[:message] || default_message)
    else
      return true
    end
  end

end

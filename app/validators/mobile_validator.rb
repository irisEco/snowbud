class MobileValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return true if value.blank? || value =~ /\A(13\d|14\d|15\d|16\d|17\d|18\d|19\d)\d{8}\z/i

    record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid'))
  end

end

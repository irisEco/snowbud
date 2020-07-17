class EmailValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return true if value.blank? || value =~ /^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/

    record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid'))
  end

end

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # http://edgeguides.rubyonrails.org/active_record_validations.html#custom-validators
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "невалиден имейл")
    end
  end
end

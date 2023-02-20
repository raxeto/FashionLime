module ActiveRecordExtension

  require 'obscenity/active_model'

  include Modules::CurrencyLib

  extend ActiveSupport::Concern

  # Let's say that you have an ActiveRecord class A that has an attribute :rali.
  # In an all other callbacks that are invoked after a model has changed, you can
  # check self.rali_changed? to see if there was any change to the :rali attribute.
  # That is not true for after_commit. There rali_changed? would be always false.
  # This method is a hack, to check if an attribute changed in the after_commit
  # callback.
  # http://stackoverflow.com/questions/7128073/after-commit-for-an-attribute
  def did_attr_change? record_attr
      return self.previous_changes.key?(record_attr) &&
          self.previous_changes[record_attr].first != self.previous_changes[record_attr].last
  end

  def did_attr_change_from_or_to_zero? record_attr
    return self.previous_changes.key?(record_attr) &&
            ((self.previous_changes[record_attr].first.abs < Conf.math.QTY_EPSILON &&
                self.previous_changes[record_attr].last.abs > Conf.math.QTY_EPSILON) ||
            (self.previous_changes[record_attr].first.abs > Conf.math.QTY_EPSILON &&
                self.previous_changes[record_attr].last.abs < Conf.math.QTY_EPSILON))
  end

  module ClassMethods

    def currency(*fields)
      thousands_delimiter = I18n.t 'number.currency.format.delimiter'
      fields.each do |f|
        define_method("#{f}=") do |val|
          if val.is_a?(String)
            val = val.gsub(thousands_delimiter, '')
          end
          super(val)
        end
      end
      currency_accessor(*fields)
    end

    def currency_accessor(*fields)
      fields.each do |f|
        define_method("#{f}_formatted") do ||
          num_to_currency(self.send(f))
        end
        define_method("#{f}_formatted_without_unit") do ||
          num_to_currency_without_unit(self.send(f))
        end
      end
    end

    def validates_offensive_words_in(*fields)
      fields.each do |f|
        validates f, obscenity: { message: I18n.t('errors.messages.offensive_words') }
      end
    end

  end

end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)

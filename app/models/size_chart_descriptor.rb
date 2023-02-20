class SizeChartDescriptor < ActiveRecord::Base

  include Modules::NumberLib

  # Relations
  belongs_to  :size_descriptor
  belongs_to  :size

  # Validations
  validates_numericality_of :value_from, :greater_than_or_equal_to => 0
  validates_numericality_of :value_to, :greater_than_or_equal_to => 0
  validate  :value_to_greater_than_value_to

  def value
    if value_from > 0 && value_to > 0 && value_from != value_to
      return "#{num_with_auto_precision(value_to)} - #{num_with_auto_precision(value_from)} см."
    end
    val = value_from > 0 ? value_from : value_to
    return "#{num_with_auto_precision(val)} см."
  end

  private

  def value_to_greater_than_value_to
    if value_from > 0 && value_to > 0 && value_from > value_to
      errors.add(:value_to, "дясната стойност трябва да е по-голяма или равна на лявата")
    end
  end

end

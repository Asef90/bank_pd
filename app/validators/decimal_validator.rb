# frozen_string_literal: true

class DecimalValidator < ActiveModel::EachValidator
  DECIMAL_FORMAT = /\A\d+(\.\d{1,2})?\z/

  def validate_each(record, attribute, _value)
    return if DECIMAL_FORMAT.match?(record.read_attribute_before_type_cast(attribute).to_s)

    record.errors.add(attribute, 'has wrong format, {precision:15, scale:2}')
  end
end

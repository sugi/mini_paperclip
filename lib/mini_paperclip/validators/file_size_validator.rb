# frozen_string_literal: true

module MiniPaperclip
  module Validators
    class FileSizeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        attachment_file_size_name = "#{attribute}_file_size"
        attachment_file_size = record.read_attribute_for_validation(attachment_file_size_name)
        if attachment_file_size
          if check_value = options[:less_than]
            unless attachment_file_size < check_value
              count = ActiveSupport::NumberHelper.number_to_human_size(check_value)
              record.errors.add(attribute, :less_than, { count: count })
              record.errors.add(attachment_file_size_name, :less_than, { count: count })
            end
          end
        end
      end
    end
  end
end

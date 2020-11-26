# frozen_string_literal: true

module MiniPaperclip
  module Validators
    class PresenceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if record.read_attribute_for_validation("#{attribute}_file_name").blank?
          record.errors.add(attribute, :blank)
        end
      end
    end
  end
end

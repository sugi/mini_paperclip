# frozen_string_literal: true

module MiniPaperclip
  module Validators
    class ContentTypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        allows = Array(options[:content_type])
        attachment_content_type_name = "#{attribute}_content_type"
        attachment_content_type = record.read_attribute_for_validation(attachment_content_type_name)
        if attachment_content_type && !allows.include?(attachment_content_type)
          record.errors.add(attribute, :invalid)
          record.errors.add(attachment_content_type_name, :invalid)
        end
      end
    end
  end
end

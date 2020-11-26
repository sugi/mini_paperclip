# frozen_string_literal: true

module MiniPaperclip
  module Validators
    class MediaTypeSpoofValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, attachment)
        return unless attachment.meta_content_type

        attachment_content_type = record.read_attribute_for_validation("#{attribute}_content_type")
        unless normalize(attachment.meta_content_type) == normalize(attachment_content_type)
          record.errors.add(attribute, :spoofed_media_type)
        end
      end

      def normalize(content_type)
        case content_type
        when "image/jpg"
          "image/jpeg"
        else
          content_type
        end
      end
    end
  end
end

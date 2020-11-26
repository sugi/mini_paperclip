# frozen_string_literal: true

module MiniPaperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the size of the
      # given attachment as specified.
      #
      # Examples:
      #   it { should validate_attachment_size(:avatar).
      #                 less_than(2.megabytes) }
      def validate_attachment_size(attachment_name)
        ValidateAttachmentSizeMatcher.new(attachment_name)
      end

      class ValidateAttachmentSizeMatcher
        def initialize(attachment_name)
          @attachment_name = attachment_name.to_sym
          @less_than_size = nil
        end

        def less_than(less_than_size)
          @less_than_size = less_than_size
          self
        end

        def matches?(subject)
          @subject = subject.class == Class ? subject.new : subject

          begin
            @subject.write_attribute("#{@attachment_name}_file_size", @less_than_size - 1)
            @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
            @subject.valid?
            @subject.errors[:"#{@attachment_name}_file_size"].empty?
          end && begin
            @subject.write_attribute("#{@attachment_name}_file_size", @less_than_size)
            @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
            @subject.valid?
            @subject.errors[:"#{@attachment_name}_file_size"].present?
          end
        end

        def failure_message
          "Attachment :#{@attachment_name} should be less than #{human_size}"
        end

        def failure_message_when_negated
          "Attachment :#{@attachment_name} should not be less than #{human_size}"
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "validate the size of attachment :#{@attachment_name}"
        end

        def human_size
          ActiveSupport::NumberHelper.number_to_human_size(@less_than_size)
        end
      end
    end
  end
end

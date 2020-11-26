# frozen_string_literal: true

module MiniPaperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the presence of the
      # given attachment.
      #
      # describe User do
      #   it { should validate_attachment_presence(:avatar) }
      # end
      def validate_attachment_presence(attachment_name)
        ValidateAttachmentPresenceMatcher.new(attachment_name)
      end

      class ValidateAttachmentPresenceMatcher
        def initialize(attachment_name)
          @attachment_name = attachment_name.to_sym
        end

        def matches?(subject)
          @subject = subject.class == Class ? subject.new : subject

          begin
            @subject.write_attribute("#{@attachment_name}_file_name", 'hello.png')
            @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
            @subject.valid?
            @subject.errors[@attachment_name].empty?
          end && begin
            @subject.write_attribute("#{@attachment_name}_file_name", nil)
            @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
            @subject.valid?
            @subject.errors[@attachment_name].present?
          end
        end

        def failure_message
          "Attachment :#{@attachment_name} should be required"
        end

        def failure_message_when_negated
          "Attachment :#{@attachment_name} should not be required"
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "require presence of attachment :#{@attachment_name}"
        end
      end
    end
  end
end

# frozen_string_literal: true

module MiniPaperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the content type of
      # the given attachment as specified.
      #
      # Example:
      #   describe User do
      #     it { should validate_attachment_content_type(:icon).
      #                   allowing('image/png', 'image/gif').
      #                   rejecting('text/plain', 'text/xml') }
      #   end
      def validate_attachment_content_type(attachment_name)
        ValidateAttachmentContentTypeMatcher.new(attachment_name)
      end

      class ValidateAttachmentContentTypeMatcher
        def initialize(attachment_name)
          @attachment_name = attachment_name.to_sym
          @allowings = []
          @rejectings = []
          @fails = []
        end

        def allowing(*allowings)
          @allowings.concat(allowings)
          self
        end

        def rejecting(*rejectings)
          @rejectings.concat(rejectings)
          self
        end

        def matches?(subject)
          @subject = subject.class == Class ? subject.new : subject

          begin
            fails = @allowings.reject do |allowing|
              @subject.write_attribute("#{@attachment_name}_content_type", allowing)
              @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
              @subject.valid?
              @subject.errors[:"#{@attachment_name}_content_type"].empty?
            end
            @fails.concat(fails).empty?
          end && begin
            fails = @rejectings.reject do |rejecting|
              @subject.write_attribute("#{@attachment_name}_content_type", rejecting)
              @subject.write_attribute("#{@attachment_name}_updated_at", Time.now)
              @subject.valid?
              @subject.errors[:"#{@attachment_name}_content_type"].present?
            end
            @fails.concat(fails).empty?
          end
        end

        def failure_message
          [
            "Attachment :#{@attachment_name} expected to",
            "  allowing #{@allowings}",
            "  rejecting #{@rejectings}",
            "  but failed #{@fails}"
          ].join("\n")
        end

        def failure_message_when_negated
          [
            "Attachment :#{@attachment_name} NOT expected to",
            "  allowing #{@allowings}",
            "  rejecting #{@rejectings}",
            "  but failed #{@fails}"
          ].join("\n")
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "validate the content types allowed on attachment :#{@attachment_name}"
        end
      end
    end
  end
end

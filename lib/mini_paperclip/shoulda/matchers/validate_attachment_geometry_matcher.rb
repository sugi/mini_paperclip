# frozen_string_literal: true

module MiniPaperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the geometry of
      # the given attachment as specified.
      #
      # Example:
      #   describe User do
      #     it { should validate_attachment_geometry(:icon)
      #                   .format(:png)
      #                   .width(less_than_or_equal_to: 100)
      #                   .height(less_than_or_equal_to: 100)
      #   end
      def validate_attachment_geometry(attachment_name)
        ValidateAttachmentGeometryMatcher.new(attachment_name)
      end

      class ValidateAttachmentGeometryMatcher
        CallError = Class.new(StandardError)

        def initialize(attachment_name)
          @attachment_name = attachment_name.to_sym
          @width = {}
          @height = {}
          @format = nil
        end

        def format(format)
          @format = format
          self
        end

        def width(less_than_or_equal_to:)
          @width[:less_than_or_equal_to] = less_than_or_equal_to
          self
        end

        def height(less_than_or_equal_to:)
          @height[:less_than_or_equal_to] = less_than_or_equal_to
          self
        end

        def matches?(subject)
          @subject = subject.class == Class ? subject.new : subject

          unless @format && !@width.empty? && !@height.empty?
            raise CallError, [
              "should call like this",
              "  it { should validate_attachment_geometry(:image)",
              "                .format(:png)",
              "                .width(less_than_or_equal_to: 3000)",
              "                .height(less_than_or_equal_to: 3000) }"
            ].join("\n")
          end

          when_valid && when_invalid
        end

        def failure_message
          [
            "Attachment :#{@attachment_name} got details",
            @subject.errors.details[@attachment_name]
          ].join("\n")
        end

        def failure_message_when_negated
          [
            "Attachment :#{@attachment_name} got details",
            @subject.errors.details[@attachment_name]
          ].join("\n")
        end

        private

        def when_valid
          create_dummy_image(width: @width[:less_than_or_equal_to], height: @height[:less_than_or_equal_to]) do |f|
            @subject.public_send("#{@attachment_name}=", f)
          end
          @subject.valid?
          @subject.errors.details[:image]&.find { |d| d[:error] == :geometry }.nil?
        end

        def when_invalid
          create_dummy_image(width: @width[:less_than_or_equal_to] + 1, height: @height[:less_than_or_equal_to] + 1) do |f|
            @subject.public_send("#{@attachment_name}=", f)
          end
          @subject.valid?
          detail = @subject.errors.details[:image]&.find { |d| d[:error] == :geometry }
          return false unless detail
          return false unless detail[:expected_width_less_than_or_equal_to] == @width[:less_than_or_equal_to]
          return false unless detail[:expected_height_less_than_or_equal_to] == @height[:less_than_or_equal_to]
          true
        end

        def create_dummy_image(width:, height:)
          Tempfile.create(['MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher', ".#{@format}"]) do |f|
            MiniMagick::Tool::Convert.new do |convert|
              convert.size("#{width}x#{height}")
              convert.xc("none")
              convert.strip
              convert << f.path
            end
            yield f
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module MiniPaperclip
  module Validators
    class GeometryValidator < ActiveModel::EachValidator
      Error = Class.new(StandardError)
      ALLOW_OPTIONS = [:less_than_or_equal_to]

      def check_validity!
        [:width, :height].each do |key|
          if options[key]
            keys = ALLOW_OPTIONS & options[key].keys
            if keys.empty?
              raise ArgumentError, ":#{key} option should specify the :less_than_or_equal_to ."
            end
          end
        end
      end

      # validate_attachment :image,
      #   geometry: {
      #     width: { less_than_or_equal_to: 3000 },
      #     height: { less_than_or_equal_to: 3000 } }
      def validate_each(record, attribute, value)
        return unless value.waiting_write_file
        image_size = ImageSize.new(value.waiting_write_file)
        # invalid format should not relate geometry
        return unless image_size.format

        expected_width_less_than_or_equal_to = options.dig(:width, :less_than_or_equal_to)
        expected_height_less_than_or_equal_to = options.dig(:height, :less_than_or_equal_to)
        unless (!expected_width_less_than_or_equal_to || image_size.width <= expected_width_less_than_or_equal_to) &&
            (!expected_height_less_than_or_equal_to || image_size.height <= expected_height_less_than_or_equal_to)
          record.errors.add(attribute, :geometry, {
            actual_width: image_size.width,
            actual_height: image_size.height,
            expected_width_less_than_or_equal_to: expected_width_less_than_or_equal_to,
            expected_height_less_than_or_equal_to: expected_height_less_than_or_equal_to,
          })
        end
      end
    end
  end
end

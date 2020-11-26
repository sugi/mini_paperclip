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
        geometry_string = MiniMagick::Tool::Identify.new do |identify|
          identify.format "%w,%h"
          identify << value.waiting_write_file.path
        end
        return unless !geometry_string.empty?
        width, height = geometry_string.split(',').map(&:to_i)

        expected_width_less_than_or_equal_to = options.dig(:width, :less_than_or_equal_to)
        expected_height_less_than_or_equal_to = options.dig(:height, :less_than_or_equal_to)
        unless (!expected_width_less_than_or_equal_to || width <= expected_width_less_than_or_equal_to) &&
            (!expected_height_less_than_or_equal_to || height <= expected_height_less_than_or_equal_to)
          record.errors.add(attribute, :geometry, {
            actual_width: width,
            actual_height: height,
            expected_width_less_than_or_equal_to: expected_width_less_than_or_equal_to,
            expected_height_less_than_or_equal_to: expected_height_less_than_or_equal_to,
          })
        end
      end
    end
  end
end

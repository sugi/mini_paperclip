# frozen_string_literal: true

module MiniPaperclip
  module Storage
    class Base
      attr_reader :attachment, :config, :interpolator

      def initialize(attachment, config)
        @attachment = attachment
        @config = config
        @interpolator = Interpolator.new(attachment, config)
      end

      def url_for_read(style)
        "#{@config.url_scheme}://#{host}/#{path_for(style)}"
      end

      def path_for(style)
        template = if @attachment.original_filename.nil?
          @config.url_missing_path
        else
          @config.url_path
        end
        interpolate(template, style)
      end

      def interpolate(template, style)
        @interpolator.interpolate(template, style)
      end

      private

      def debug(str)
        MiniPaperclip.config.logger.debug(str)
      end
    end
  end
end

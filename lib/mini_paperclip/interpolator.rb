# frozen_string_literal: true

module MiniPaperclip
  class Interpolator
    attr_reader :attachment, :config

    def initialize(attachment, config)
      @attachment = attachment
      @config = config
    end

    def interpolate(template, style)
      template.dup.tap do |t|
        @config.interpolates&.each do |matcher, block|
          t.gsub!(matcher) { instance_exec(style, &block) }
        end
      end
    end

    private

    def class_result
      @attachment.record.class.name.underscore.pluralize
    end

    def attachment_result
      @attachment.attachment_name.to_s.downcase.pluralize
    end

    def extension
      attachment.original_filename &&
        File.extname(attachment.original_filename)[1..-1]
    end

    def hash_key(style)
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA1.new,
        @config.hash_secret,
        interpolated_hash_data(style),
      )
    end

    def interpolated_hash_data(style)
      interpolate(@config.hash_data, style)
    end
  end
end

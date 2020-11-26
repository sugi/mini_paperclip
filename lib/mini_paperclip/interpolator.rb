# frozen_string_literal: true

module MiniPaperclip
  class Interpolator
    def initialize(record, attachment_name, config)
      @record = record
      @attachment_name = attachment_name
      @config = config
    end

    def interpolate(template, style)
      template.dup.tap do |t|
        @config.interpolates&.each do |matcher, block|
          t.gsub!(matcher) { instance_exec(attachment, style, &block) }
        end
      end
    end

    private

    def class_result
      @record.class.name.underscore.pluralize
    end

    def attachment_result
      @attachment_name.to_s.downcase.pluralize
    end

    def attachment
      @record.public_send(@attachment_name)
    end

    def hash_key(style)
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA1.new,
        @config.hash_secret,
        interpolate(@config.hash_data, style),
      )
    end
  end
end

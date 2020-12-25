# frozen_string_literal: true

require "openssl"
require "net/http"
require "active_model/validator"
require "active_support"
require "active_support/number_helper"
require "mini_magick"
require "mimemagic"
require "aws-sdk-s3"
require "image_size"

require "mini_paperclip/attachment"
require "mini_paperclip/class_methods"
require "mini_paperclip/config"
require "mini_paperclip/interpolator"
require "mini_paperclip/storage"
require "mini_paperclip/validators"
require "mini_paperclip/version"

module MiniPaperclip
  class << self
    def config
      @config ||= Config.new(
        # defaults
        interpolates: {
          ':class' => ->(_) { class_result },
          ':attachment' => ->(_) { attachment_result },
          ':hash' => ->(style) { hash_key(style) },
          ':extension' => ->(_) { extension },
          ':id' => ->(_) { @attachment.record.id },
          ':updated_at' => ->(_) { attachment.updated_at&.to_i },
          ':style' => ->(style) { style }
        },
        hash_data: ":class/:attachment/:id/:style/:updated_at",
        url_missing_path: ":attachment/:style/missing.png",
        keep_old_files: false,
        read_timeout: 60,
        logger: Logger.new($stdout),
      )
    end
  end
end

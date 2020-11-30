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
          /:class/ => ->(*) { class_result },
          /:attachment/ => ->(*) { attachment_result },
          /:hash/ => ->(_, style) { hash_key(style) },
          /:extension/ => ->(*) { File.extname(@record.read_attribute("#{@attachment_name}_file_name"))[1..-1] },
          /:id/ => ->(*) { @record.id },
          /:updated_at/ => ->(*) { @record.read_attribute("#{@attachment_name}_updated_at").to_i },
          /:style/ => ->(_, style) { style }
        },
        hash_data: ":class/:attribute/:id/:style/:updated_at",
        url_missing_path: ":attachment/:style/missing.png",
        read_timeout: 60,
        logger: Logger.new($stdout),
      )
    end
  end
end

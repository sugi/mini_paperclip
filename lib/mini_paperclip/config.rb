# frozen_string_literal: true

module MiniPaperclip
  class Config < Struct.new(
    :storage,
    :filesystem_path,
    :hash_secret,
    :hash_data,
    :styles,
    :url_scheme,
    :url_host,
    :url_path,
    :url_missing_path,
    :s3_host_alias,
    :s3_bucket_name,
    :s3_acl,
    :s3_cache_control,
    :interpolates,
    :keep_old_files,
    :read_timeout,
    :logger,
    keyword_init: true,
  )
    def merge(hash)
      dup.merge!(hash)
    end

    def merge!(hash)
      to_h.deep_merge(hash.to_h).each { |k, v| self[k] = v }
      self
    end
  end
end

# frozen_string_literal: true

module MiniPaperclip
  module Storage
    class S3 < Base
      def write(style, file)
        debug("writing by S3 to bucket:#{@config.s3_bucket_name},key:#{s3_object_key(style)}")
        Aws::S3::Client.new.put_object(
          acl: @config.s3_acl,
          cache_control: @config.s3_cache_control,
          content_type: @attachment.content_type,
          body: file.tap(&:rewind),
          bucket: @config.s3_bucket_name,
          key: s3_object_key(style),
        )
        @deletes.delete({ key: s3_object_key(style) }) # cancel deletion if overwrite
      end

      def s3_object_key(style)
        interpolate(@config.url_path, style)
      end

      def host
        # AWS CloudFront origin should be attached bucket name
        @config.s3_host_alias || "#{@config.s3_bucket_name}.#{@config.url_host}"
      end

      def exists?(style)
        Aws::S3::Client.new.head_object(
          bucket: @config.s3_bucket_name,
          key: s3_object_key(style),
        )
        true
      rescue Aws::S3::Errors::NotFound
        false
      end

      def push_delete_file(style)
        @deletes.push({ key: s3_object_key(style) })
      end

      def do_delete_files
        return if @deletes.empty?
        debug("deleting by S3 to bucket:#{@config.s3_bucket_name},objects:#{@deletes}")
        Aws::S3::Client.new.delete_objects(
          bucket: @config.s3_bucket_name,
          delete: {
            objects: @deletes,
            quiet: true,
          }
        )
      end

      def open(style)
        Tempfile.new(['MiniPaperclip::Storage::S3']).tap do |response_target|
          response_target.binmode
          Aws::S3::Client.new.get_object(
            bucket: @config.s3_bucket_name,
            key: s3_object_key(style),
            response_target: response_target,
          )
          yield response_target if block_given?
        end
      end
    end
  end
end

# frozen_string_literal: true

module MiniPaperclip
  module Storage
    class Filesystem < Base
      def write(style, file)
        path = file_path(style)
        debug("writing by filesystem to #{path}")
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.cp(file.path, path)
      end

      def copy(style, from_attachment)
        raise "not supported" unless from_attachment.storage.instance_of?(Filesystem)
        to_path = file_path(style)
        from_path = from_attachment.storage.file_path(style)
        debug("copying by filesystem from:#{from_path} to:#{to_path}")
        FileUtils.cp(from_path, to_path)
      end

      def file_path(style)
        interpolate(@config.filesystem_path, style)
      end

      def host
        @config.url_host
      end

      def exists?(style)
        File.exists?(file_path(style))
      end
    end
  end
end

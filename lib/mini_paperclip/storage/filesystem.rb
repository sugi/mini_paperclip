# frozen_string_literal: true

module MiniPaperclip
  module Storage
    class Filesystem < Base
      def write(style, file)
        path = file_path(style)
        debug("writing by filesystem from:#{file.path} to:#{path}")
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.cp(file.path, path) if file.path != path
        @deletes.delete(path) # cancel deletion if overwrite
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

      def push_delete_file(style)
        @deletes.push(file_path(style))
      end

      def do_delete_files
        return if @deletes.empty?
        debug("deleting by filesystem #{@deletes}")
        FileUtils.rm_f(@deletes)
      end

      def open(style, &block)
        File.open(file_path(style), 'r', &block)
      end
    end
  end
end

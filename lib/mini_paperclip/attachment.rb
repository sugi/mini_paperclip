# frozen_string_literal: true

module MiniPaperclip
  class Attachment
    UnsupportedError = Class.new(StandardError)

    attr_reader :record, :attachment_name, :config, :storage,
                :waiting_write_file, :meta_content_type

    def initialize(record, attachment_name, overwrite_config = {})
      @record = record
      @attachment_name = attachment_name
      @config = MiniPaperclip.config.merge(overwrite_config)
      @waiting_write_file = nil
      @meta_content_type = nil
      @dirty = false
      @storage = Storage.const_get(@config.storage.to_s.camelcase)
                        .new(self, @config)
    end

    def original_filename
      @record.read_attribute("#{@attachment_name}_file_name")
    end

    def content_type
      @record.read_attribute("#{@attachment_name}_content_type")
    end

    def size
      @record.read_attribute("#{@attachment_name}_file_size")
    end

    def updated_at
      @record.read_attribute("#{@attachment_name}_updated_at")
    end

    def file?
      original_filename.present?
    end
    alias_method :present?, :file?

    def blank?
      !file?
    end

    def exists?(style = :original)
      file? && @storage.exists?(style)
    end

    def url(style = :original)
      @storage.url_for_read(style)
    end

    def dirty?
      @dirty
    end

    def assign(file)
      @dirty = true
      @waiting_copy_attachment = nil
      @waiting_write_file = nil
      @meta_content_type = nil

      if file.nil?
        # clear
        @record.write_attribute("#{@attachment_name}_file_name", nil)
        @record.write_attribute("#{@attachment_name}_content_type", nil)
        @record.write_attribute("#{@attachment_name}_file_size", nil)
        @record.write_attribute("#{@attachment_name}_updated_at", nil)
      elsif file.instance_of?(Attachment)
        # copy
        @record.write_attribute("#{@attachment_name}_file_name", file.record.read_attribute("#{@attachment_name}_file_name"))
        @record.write_attribute("#{@attachment_name}_content_type", file.record.read_attribute("#{@attachment_name}_content_type"))
        @record.write_attribute("#{@attachment_name}_file_size", file.record.read_attribute("#{@attachment_name}_file_size"))
        @record.write_attribute("#{@attachment_name}_updated_at", Time.current)
        @waiting_copy_attachment = file
      elsif file.respond_to?(:original_filename)
        # e.g. ActionDispatch::Http::UploadedFile
        @record.write_attribute("#{@attachment_name}_file_name", file.original_filename)
        @record.write_attribute("#{@attachment_name}_content_type", strict_content_type(file.to_io))
        @record.write_attribute("#{@attachment_name}_file_size", file.size)
        @record.write_attribute("#{@attachment_name}_updated_at", Time.current)
        @waiting_write_file = build_tempfile(file.tap(&:rewind))
        @meta_content_type = file.content_type
      elsif file.respond_to?(:path)
        # e.g. File
        @record.write_attribute("#{@attachment_name}_file_name", File.basename(file.path))
        @record.write_attribute("#{@attachment_name}_content_type", strict_content_type(file))
        @record.write_attribute("#{@attachment_name}_file_size", file.size)
        @record.write_attribute("#{@attachment_name}_updated_at", Time.current)
        @waiting_write_file = build_tempfile(file.tap(&:rewind))
      elsif file.instance_of?(String)
        if file.empty?
          # do nothing
        elsif file.start_with?('http')
          # download from url
          open_uri_option = {
            read_timeout: MiniPaperclip.config.read_timeout || 60
          }
          uri = URI.parse(file)
          uri.open(open_uri_option) do |io|
            @record.write_attribute("#{@attachment_name}_file_name", File.basename(uri.path))
            @record.write_attribute("#{@attachment_name}_content_type", strict_content_type(io))
            @record.write_attribute("#{@attachment_name}_file_size", io.size)
            @record.write_attribute("#{@attachment_name}_updated_at", Time.current)
            @waiting_write_file = build_tempfile(io.tap(&:rewind))
            @meta_content_type = io.meta["content-type"]
          end
        elsif file.start_with?('data:')
          # data-uri
          match_data = file.match(/\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m)
          if match_data.nil?
            raise UnsupportedError, "attachment for \"#{file[0..100]}\" is not supported"
          end
          raw = Base64.decode64(match_data[2])
          @record.write_attribute("#{@attachment_name}_file_name", nil)
          @record.write_attribute("#{@attachment_name}_content_type", strict_content_type(StringIO.new(raw)))
          @record.write_attribute("#{@attachment_name}_file_size", raw.bytesize)
          @record.write_attribute("#{@attachment_name}_updated_at", Time.current)
          @waiting_write_file = build_tempfile(StringIO.new(raw))
          @meta_content_type = match_data[1]
        else
          raise UnsupportedError, "attachment for \"#{file[0..100]}\" is not supported"
        end
      else
        raise UnsupportedError, "attachment for #{file.class} is not supported"
      end
    end

    def process_and_store
      return unless file?

      if @waiting_copy_attachment
        debug("start attachment copy")
        @storage.copy(:original, @waiting_copy_attachment)
        @config.styles&.each do |style, size_arg|
          @storage.copy(style, @waiting_copy_attachment)
        end
        @waiting_copy_attachment = nil
        return
      end

      return if @waiting_write_file.nil?

      begin
        debug("start attachment styles process")
        @storage.write(:original, @waiting_write_file)
        @config.styles&.each do |style, size_arg|
          Tempfile.create([style.to_s, File.extname(@waiting_write_file.path)]) do |temp|
            MiniMagick::Tool::Convert.new do |convert|
              convert << @waiting_write_file.path
              convert.auto_orient
              if size_arg.end_with?('#')
                # crop option
                convert.resize("#{size_arg[0..-2]}^")
                convert.gravity("center")
                convert.extent(size_arg[0..-2])
              else
                convert.resize(size_arg)
              end
              convert << temp.path
            end
            @storage.write(style, temp)
          end
        end
      ensure
        @waiting_write_file.close!
      end
      @waiting_write_file = nil
    end

    def push_delete_files
      @storage.push_delete_file(:original)
      @config.styles&.each_key do |style|
        @storage.push_delete_file(style)
      end
    end

    def do_delete_files
      @storage.do_delete_files
    end

    private

    def strict_content_type(io)
      io.rewind
      MimeMagic.by_magic(io)&.type
    end

    def build_tempfile(io)
      temp = Tempfile.new(['MiniPaperclip'])
      temp.binmode
      debug("copying by tempfile from:#{io.class} to:#{temp.path}")
      IO.copy_stream(io, temp)
      temp.rewind
      temp
    end

    def debug(str)
      MiniPaperclip.config.logger.debug("[mini_paperclip] #{str}")
    end
  end
end

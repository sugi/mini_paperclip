# frozen_string_literal: true

module MiniPaperclip
  module ClassMethods
    def has_attached_file(attachment_name, option_config = {})
      define_method(attachment_name) do
        instance_variable_get("@#{attachment_name}") or
          instance_variable_set("@#{attachment_name}", Attachment.new(self, attachment_name, option_config))
      end
      define_method("#{attachment_name}=") do |file|
        a = public_send(attachment_name)
        a.assign(file)
        instance_variable_set("@#{attachment_name}", a)
      end
      after_save do
        if valid?
          instance_variable_get("@#{attachment_name}")&.tap do |a|
            a.dirty? && a.process_and_store
          end
        end
      end
      before_destroy do
        public_send(attachment_name).push_delete_files
      end
      after_commit(on: :destroy) do
        public_send(attachment_name).do_delete_files
      end
      validates_with Validators::MediaTypeSpoofValidator, {
        attributes: attachment_name,
        if: -> { instance_variable_get("@#{attachment_name}")&.dirty? }
      }
    end

    def validates_attachment(attachment_name, content_type: nil, size: nil, presence: nil, geometry: nil, **opts)
      if content_type
        validates_with Validators::ContentTypeValidator, {
          attributes: attachment_name.to_sym,
          **content_type,
          **opts,
        }
      end

      if size
        validates_with Validators::FileSizeValidator, {
          attributes: attachment_name.to_sym,
          **size,
          **opts,
        }
      end

      if !presence.nil?
        validates_with Validators::PresenceValidator, {
          attributes: attachment_name.to_sym,
          presence: presence,
          **opts,
        }
      end

      if geometry
        validates_with Validators::GeometryValidator, {
          attributes: attachment_name.to_sym,
          **geometry,
          **opts,
        }
      end
    end
  end
end

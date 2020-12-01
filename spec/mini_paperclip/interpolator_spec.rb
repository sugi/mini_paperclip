RSpec.describe MiniPaperclip::Interpolator do
  let(:record) { Record.new }

  it "#interpolate" do
    record.image_file_name = 'image.png'
    attachment = MiniPaperclip::Attachment.new(record, 'image', MiniPaperclip.config)
    i = MiniPaperclip::Interpolator.new(attachment, MiniPaperclip.config)
    original = i.interpolate(':class/:attachment/:hash.:extension', :original)
    expect(original).to match(%r{records/images/[a-z0-9]+\.png})
    medium = i.interpolate(':class/:attachment/:hash.:extension', :medium)
    expect(medium).to_not eq(original)
  end
end

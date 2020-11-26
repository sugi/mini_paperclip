RSpec.describe MiniPaperclip::Interpolator do
  let(:record) { Record.new }

  it "#interpolate" do
    record.image_file_name = 'image.png'
    i = MiniPaperclip::Interpolator.new(record, 'image', MiniPaperclip.config)
    original = i.interpolate(':class/:attachment/:hash.:extension', :original)
    expect(original).to match(%r{records/images/[a-z0-9]+\.png})
    medium = i.interpolate(':class/:attachment/:hash.:extension', :medium)
    expect(medium).to_not eq(original)
  end
end

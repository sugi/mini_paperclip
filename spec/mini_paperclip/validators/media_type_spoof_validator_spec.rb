RSpec.describe MiniPaperclip::Validators::MediaTypeSpoofValidator do
  it "#validate_each should valid when same content type" do
    validator = MiniPaperclip::Validators::MediaTypeSpoofValidator.new(
      attributes: :img,
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(attachment).to receive(:meta_content_type).and_return('image/png')
    allow(mock).to receive(:read_attribute_for_validation).with('img_content_type').and_return('image/png')
    expect(mock).to_not receive(:errors)
    validator.validate_each(mock, :img, attachment)
  end

  it "#validate_each should invalid when another content type" do
    validator = MiniPaperclip::Validators::MediaTypeSpoofValidator.new(
      attributes: :img,
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(attachment).to receive(:meta_content_type).and_return('image/jpeg')
    allow(mock).to receive(:read_attribute_for_validation).with('img_content_type').and_return('image/png')
    errors_mock = double('Errors')
    allow(mock).to receive(:errors).and_return(errors_mock)
    expect(errors_mock).to receive(:add).with(:img, :spoofed_media_type)
    validator.validate_each(mock, :img, attachment)
  end
end

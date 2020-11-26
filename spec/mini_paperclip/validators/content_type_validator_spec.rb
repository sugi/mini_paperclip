RSpec.describe MiniPaperclip::Validators::ContentTypeValidator do
  it "#validate_each with valid content type" do
    validator = MiniPaperclip::Validators::ContentTypeValidator.new(
      attributes: :img,
      content_type: ['image/png']
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with('img_content_type').and_return('image/png')
    expect(mock).to_not receive(:errors)
    validator.validate_each(mock, :img, attachment)
  end

  it "#validate_each with invalid content type" do
    validator = MiniPaperclip::Validators::ContentTypeValidator.new(
      attributes: :img,
      content_type: ['image/png']
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with('img_content_type').and_return('image/jpeg')
    errors_mock = double('Errors')
    allow(mock).to receive(:errors).and_return(errors_mock)
    expect(errors_mock).to receive(:add).with(:img, :invalid)
    expect(errors_mock).to receive(:add).with("img_content_type", :invalid)
    validator.validate_each(mock, :img, attachment)
  end
end

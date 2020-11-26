RSpec.describe MiniPaperclip::Validators::FileSizeValidator do
  it "#validate_each with valid file size" do
    validator = MiniPaperclip::Validators::FileSizeValidator.new(
      attributes: :img,
      less_than: 1.megabytes,
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with('img_file_size').and_return(1.kilobytes)
    expect(mock).to_not receive(:errors)
    validator.validate_each(mock, :img, attachment)
  end

  it "#validate_each with invalid file size" do
    validator = MiniPaperclip::Validators::FileSizeValidator.new(
      attributes: :img,
      less_than: 1.megabytes,
    )
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with('img_file_size').and_return(2.megabytes)
    errors_mock = double('Errors')
    allow(mock).to receive(:errors).and_return(errors_mock)
    expect(errors_mock).to receive(:add).with(:img, :less_than, { count: "1 MB" })
    expect(errors_mock).to receive(:add).with("img_file_size", :less_than, { count: "1 MB" })
    validator.validate_each(mock, :img, attachment)
  end
end

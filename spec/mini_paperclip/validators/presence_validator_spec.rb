RSpec.describe MiniPaperclip::Validators::PresenceValidator do
  it "#validate_each with file name" do
    validator = MiniPaperclip::Validators::PresenceValidator.new(attributes: :img)
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with("img_file_name").and_return("img.png")
    expect(mock).to_not receive(:errors)
    validator.validate_each(mock, :img, attachment)
  end

  it "#validate_each with empty file name" do
    validator = MiniPaperclip::Validators::PresenceValidator.new(attributes: :img)
    mock = double('Record')
    attachment = double('Attachment')
    allow(mock).to receive(:read_attribute_for_validation).with("img_file_name").and_return("")
    expect(mock).to receive_message_chain(:errors, :add).with(:img, :blank)
    validator.validate_each(mock, :img, attachment)
  end
end

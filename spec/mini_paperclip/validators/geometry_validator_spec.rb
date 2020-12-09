RSpec.describe MiniPaperclip::Validators::GeometryValidator do
  it "#validate_each with invalid image" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 1000 },
    )
    Tempfile.create(['spec']) do |f|
      f.binmode
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      expect(mock).to_not receive(:errors)
      validator.validate_each(mock, :img, attachment)
    end
  end

  it "#validate_each with valid geometry width" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 1000 },
    )
    File.open("spec/paperclip.jpg", 'r') do |f|
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      expect(mock).to_not receive(:errors)
      validator.validate_each(mock, :img, attachment)
    end
  end

  it "#validate_each with valid geometry width and height" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 1000 },
      height: { less_than_or_equal_to: 1000 },
    )
    File.open("spec/paperclip.jpg", 'r') do |f|
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      expect(mock).to_not receive(:errors)
      validator.validate_each(mock, :img, attachment)
    end
  end

  it "#validate_each with valid geometry width and invalid geometry height" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 1000 },
      height: { less_than_or_equal_to: 10 },
    )
    File.open("spec/paperclip.jpg", 'r') do |f|
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      errors_mock = double('Errors')
      allow(mock).to receive(:errors).and_return(errors_mock)
      expect(errors_mock).to receive(:add).with(
        :img,
        :geometry,
        {
          expected_width_less_than_or_equal_to: 1000,
          expected_height_less_than_or_equal_to: 10,
          actual_width: 490,
          actual_height: 275,
        }
      )
      validator.validate_each(mock, :img, attachment)
    end
  end

  it "#validate_each with valid geometry width" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 10 },
    )

    File.open("spec/paperclip.jpg", 'r') do |f|
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      errors_mock = double('Errors')
      allow(mock).to receive(:errors).and_return(errors_mock)
      expect(errors_mock).to receive(:add).with(
        :img,
        :geometry,
        {
          expected_width_less_than_or_equal_to: 10,
          expected_height_less_than_or_equal_to: nil,
          actual_width: 490,
          actual_height: 275,
        }
      )
      validator.validate_each(mock, :img, attachment)
    end
  end

  it "#validate_each with valid geometry width and height" do
    validator = MiniPaperclip::Validators::GeometryValidator.new(
      attributes: :img,
      width: { less_than_or_equal_to: 10 },
      height: { less_than_or_equal_to: 10 },
    )

    File.open("spec/paperclip.jpg", 'r') do |f|
      mock = double('Record')
      attachment = double('Attachment')
      allow(attachment).to receive(:waiting_write_file).and_return(f)
      errors_mock = double('Errors')
      allow(mock).to receive(:errors).and_return(errors_mock)
      expect(errors_mock).to receive(:add).with(
        :img,
        :geometry,
        {
          expected_width_less_than_or_equal_to: 10,
          expected_height_less_than_or_equal_to: 10,
          actual_width: 490,
          actual_height: 275,
        }
      )
      validator.validate_each(mock, :img, attachment)
    end
  end
end

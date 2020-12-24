RSpec.describe MiniPaperclip::Storage::Base do
  let(:record) { Record.new }

  it "#path_for with missing file" do
    attachment = MiniPaperclip::Attachment.new(record, :image)
    config = MiniPaperclip.config.dup
    base = MiniPaperclip::Storage::Base.new(attachment, config)
    expect(base.path_for(:original)).to eq('images/original/missing.png')
  end

  it "#path_for with empty file" do
    attachment = MiniPaperclip::Attachment.new(record, :image)
    config = MiniPaperclip.config.dup
    base = MiniPaperclip::Storage::Base.new(attachment, config)
    record.image_file_name = ""
    expect(base.path_for(:original)).to eq('records/images/25a80ba6aa8c48f17ea32fc7935fab633e807238.')
  end

  it "#path_for with file" do
    attachment = MiniPaperclip::Attachment.new(record, :image)
    config = MiniPaperclip.config.dup
    base = MiniPaperclip::Storage::Base.new(attachment, config)
    record.image_file_name = "test.png"
    expect(base.path_for(:original)).to eq('records/images/25a80ba6aa8c48f17ea32fc7935fab633e807238.png')
  end
end

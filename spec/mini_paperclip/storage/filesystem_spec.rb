RSpec.describe MiniPaperclip::Storage::Filesystem do
  let(:record) { Record.new }

  it "#write" do
    record.image_file_name = 'image.png'
    attachment = MiniPaperclip::Attachment.new(record, :image)
    filesystem = MiniPaperclip::Storage::Filesystem.new(attachment, MiniPaperclip.config)
    file = double('File')
    allow(file).to receive(:path).and_return('file.png')
    expect(FileUtils).to receive(:cp).with('file.png', %r{spec/temp/records/images/.*.png})
    filesystem.write(:original, file)
  end

  it "#copy" do
    from_record = Record.new(image_file_name: 'image.png')
    to_record = Record.new(image_file_name: 'image.png')
    from_attachment = MiniPaperclip::Attachment.new(from_record, :image, { storage: :filesystem })
    to_attachment = MiniPaperclip::Attachment.new(to_record, :image)

    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    from_attachment.assign(file)
    from_attachment.process_and_store
    filesystem = MiniPaperclip::Storage::Filesystem.new(to_attachment, MiniPaperclip.config)
    expect(filesystem.exists?(:original)).to eq(false)
    filesystem.copy(:original, from_attachment)
    expect(filesystem.exists?(:original)).to eq(true)
  end
end

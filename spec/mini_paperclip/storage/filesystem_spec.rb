RSpec.describe MiniPaperclip::Storage::Filesystem do
  let(:record) { Record.new }

  it "#write" do
    record.image_file_name = 'image.png'
    filesystem = MiniPaperclip::Storage::Filesystem.new(record, :image, MiniPaperclip.config)
    file = double('File')
    allow(file).to receive(:path).and_return('file.png')
    expect(FileUtils).to receive(:cp).with('file.png', %r{spec/temp/records/images/.*.png})
    filesystem.write(:original, file)
  end
end

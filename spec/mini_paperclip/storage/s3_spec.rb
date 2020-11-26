RSpec.describe MiniPaperclip::Storage::S3 do
  let(:record) { Record.new }

  it "#write" do
    record.image_file_name = 'image.png'
    s3 = MiniPaperclip::Storage::S3.new(record, :image, MiniPaperclip.config.merge(
      s3_bucket_name: 'bucket',
    ))
    file = double('File')
    allow(file).to receive(:rewind)
    expect_any_instance_of(Aws::S3::Client).to receive(:put_object)
    s3.write(:original, file)
  end
end

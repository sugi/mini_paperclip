RSpec.describe MiniPaperclip::Storage::S3 do
  let(:record) { Record.new }

  it "#write" do
    record.image_file_name = 'image.png'
    attachment = MiniPaperclip::Attachment.new(record, :image)
    s3 = MiniPaperclip::Storage::S3.new(attachment, MiniPaperclip.config.merge(
      s3_bucket_name: 'bucket',
    ))
    file = double('File')
    allow(file).to receive(:rewind)
    expect_any_instance_of(Aws::S3::Client).to receive(:put_object)
    s3.write(:original, file)
  end

  it "#open" do
    record.image_file_name = 'image.png'
    attachment = MiniPaperclip::Attachment.new(record, :image)
    s3 = MiniPaperclip::Storage::S3.new(attachment, MiniPaperclip.config.merge(
      s3_bucket_name: 'bucket',
    ))
    file = Rack::Test::UploadedFile.new("spec/paperclip.jpg", 'image/jpeg')
    aws_stub_response({
      put_object: {},
    }) do
      s3.write(:original, file)
      expect_any_instance_of(Aws::S3::Client).to receive(:get_object)
      expect(s3.open(:original)).to be_instance_of(Tempfile)
    end
  end
end

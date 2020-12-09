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
      get_object: ->(context) {
        context.metadata[:response_target].tap { |f|
          f.write(file.read)
          f.flush
        }
      },
    }) do
      s3.write(:original, file)
      expect(s3.open(:original).tap(&:rewind).read[0..100]).to eq(file.tap(&:rewind).read[0..100])
    end
  end
end

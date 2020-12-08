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

  it "#copy" do
    from_record = Record.new(image_file_name: 'image.png')
    to_record = Record.new(image_file_name: 'image.png')
    from_attachment = MiniPaperclip::Attachment.new(from_record, :image, { storage: :s3 })
    to_attachment = MiniPaperclip::Attachment.new(to_record, :image, { storage: :s3 })
    s3 = MiniPaperclip::Storage::S3.new(to_attachment, MiniPaperclip.config.merge(
      s3_bucket_name: 'bucket',
    ))
    expect_any_instance_of(Aws::S3::Client).to receive(:copy_object)
      .with(
        acl: nil,
        cache_control: nil,
        content_type: nil,
        bucket: 'bucket',
        copy_source: "records/images/25a80ba6aa8c48f17ea32fc7935fab633e807238.png",
        key: "records/images/25a80ba6aa8c48f17ea32fc7935fab633e807238.png"
      )
    s3.copy(:original, from_attachment)
  end
end

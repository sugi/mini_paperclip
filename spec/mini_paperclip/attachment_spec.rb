RSpec.describe MiniPaperclip::Attachment do
  let(:record) { Record.new }

  it "#exists? with filesystem" do
    a = MiniPaperclip::Attachment.new(record, :image, { storage: :filesystem })
    expect(a.exists?).to eq(false)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.process_and_store
    expect(a.exists?).to eq(true)
  end

  it "#exists? with s3" do
    orig_config = Aws.config
    Aws.config[:stub_responses] = {
      head_object: {content_length: 0},
      put_object: ->(context) {
        context.config[:stub_responses][:head_object][:content_length] = 1
      },
    }

    a = MiniPaperclip::Attachment.new(record, :image, { storage: :s3, s3_bucket_name: 'bucket' })
    expect(a.exists?).to eq(false)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.process_and_store
    expect(a.exists?).to eq(true)
  ensure
    Aws.config = orig_config
  end

  it "#url with filesystem should get url" do
    a = MiniPaperclip::Attachment.new(record, :image, { storage: :filesystem })
    url = URI.parse(a.url)
    expect(url.scheme).to eq('http')
    expect(url.path).to eq('/images/original/missing.png')
  end

  it "#url with s3 should get url" do
    a = MiniPaperclip::Attachment.new(record, :image, { storage: :s3, s3_bucket_name: 'bucket' })
    url = URI.parse(a.url)
    expect(url.scheme).to eq('http')
    expect(url.host).to eq('bucket.test.com')
    expect(url.path).to eq('/images/original/missing.png')

    a = MiniPaperclip::Attachment.new(record, :image, { storage: :s3, s3_host_alias: 'cl.com' })
    url = URI.parse(a.url)
    expect(url.scheme).to eq('http')
    expect(url.host).to eq('cl.com')
    expect(url.path).to eq('/images/original/missing.png')
  end

  it "#assign with nil" do
    a = MiniPaperclip::Attachment.new(record, :image)
    file = nil
    a.assign(file)

    expect(record.image_content_type).to eq(nil)
    expect(record.image_file_size).to eq(nil)
    expect(record.image_file_name).to eq(nil)
    expect(record.image_updated_at).to eq(nil)
  end

  it "#assign with UploadedFile" do
    a = MiniPaperclip::Attachment.new(record, :image)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    file.close

    expect(record.image_content_type).to eq('image/jpeg')
    expect(record.image_file_size).to be > 0
    expect(record.image_file_name).to eq('paperclip.jpg')
    expect(a.waiting_write_file).to_not be_closed
  end

  it "#assign with Attachment" do
    a = MiniPaperclip::Attachment.new(record, :image)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    b = MiniPaperclip::Attachment.new(record, :image)
    b.assign(a)

    expect(a.record.image_content_type).to eq(b.record.image_content_type)
    expect(a.record.image_file_size).to eq(b.record.image_file_size)
    expect(a.record.image_file_name).to eq(b.record.image_file_name)
  end

  it "#assign with File" do
    a = MiniPaperclip::Attachment.new(record, :image)
    File.open("spec/paperclip.jpg") do |f|
      a.assign(f)
      expect(record.image_content_type).to eq('image/jpeg')
      expect(record.image_file_size).to eq(f.size)
      expect(record.image_file_name).to eq("paperclip.jpg")
    end
    expect(a.waiting_write_file).to_not be_closed
  end

  it "#assign with empty string" do
    a = MiniPaperclip::Attachment.new(record, :image)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.assign("")
    expect(record.image_content_type).to eq('image/jpeg')
    expect(record.image_file_size).to be > 0
    expect(record.image_file_name).to eq("paperclip.jpg")
    expect(a.waiting_write_file).to eq(nil)
  end

  it "#assign with spoof content type URL" do
    image_url = "http://www.example.log/a.png"
    file_path = "spec/paperclip.jpg"
    stub_request(:get, image_url)
      .with(headers: {'User-Agent' => 'Ruby'})
      .to_return(
        status: 200,
        body: File.read(file_path),
        headers: { 'Content-Length' => 0, 'Content-Type' => 'image/png' })

    a = MiniPaperclip::Attachment.new(record, :image)
    a.assign(image_url)

    File.open(file_path, 'r') do |f|
      expect(record.image_content_type).to eq('image/jpeg') # ignore Content-Type
      expect(record.image_file_size).to eq(f.size) # ignore Content-Length
    end
    expect(record.image_file_name).to eq("a.png")
    expect(a.waiting_write_file).to_not be_closed
  end

  it "#assign with data-uri" do
    file_path = "spec/paperclip.jpg"
    bin = File.read(file_path)

    a = MiniPaperclip::Attachment.new(record, :image)
    a.assign("data:image/png;base64,#{Base64.strict_encode64(bin)}")

    File.open(file_path) do |f|
      expect(record.image_content_type).to eq(MimeMagic.by_magic(f).type) # ignore Content-Type
      expect(record.image_file_size).to eq(f.size) # ignore Content-Length
    end
    expect(record.image_file_name).to eq(nil)
    expect(a.waiting_write_file).to_not be_closed
  end

  it "#process_and_store should write files" do
    a = MiniPaperclip::Attachment.new(record, :image, { styles: { medium: '20x10' } })
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.process_and_store

    path = a.storage.file_path(:original)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq("490x275")

    path = a.storage.file_path(:medium)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq('18x10')
  end

  it "#process_and_store with crop should write files" do
    a = MiniPaperclip::Attachment.new(record, :image, { styles: { medium: '20x10#' } })
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.process_and_store

    path = a.storage.file_path(:original)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq("490x275")

    path = a.storage.file_path(:medium)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq('20x10')
  end

  it "#process_and_store should copy files" do
    option = {
      styles: { medium: '20x10#' },
      interpolates: {
        /:object_hash/ => ->(*) { @record.hash },
      },
      filesystem_path: "spec/temp/:class/:attachment/:style-:object_hash.:extension",
      hash_data: ":class/:attachment/:object_hash",
    }
    a = MiniPaperclip::Attachment.new(record, :image, option)
    file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    a.assign(file)
    a.process_and_store

    path = a.storage.file_path(:original)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq("490x275")
    path = a.storage.file_path(:medium)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq('20x10')

    b = MiniPaperclip::Attachment.new(Record.new, :image, option)
    b.assign(a)
    b.process_and_store

    path = b.storage.file_path(:original)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq("490x275")
    path = b.storage.file_path(:medium)
    expect(File.exists?(path)).to eq(true)
    expect(`identify -format %wx%h #{path}`).to eq('20x10')
  end
end

RSpec.describe MiniPaperclip::ClassMethods do
  let(:record) { Record.new }
  let(:png_1x1_base64) do
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQAAAAA3bvkkAAAAAnRSTlMAAHaTzTgAAAAKSURBVAjXY2AAAAACAAHiIbwzAAAAAElFTkSuQmCC"
  end

  it "should success to save and delete files on filesystem" do
    record.image = "data:image/png;base64,#{png_1x1_base64}"
    record.image_file_name = 'test.png'
    record.save!
    expect(File.exists?(record.image.storage.file_path(:original))).to eq(true)
    expect(File.exists?(record.image.storage.file_path(:medium))).to eq(true)
    record.destroy!
    expect(File.exists?(record.image.storage.file_path(:original))).to eq(false)
    expect(File.exists?(record.image.storage.file_path(:medium))).to eq(false)
  end

  it "should success to save and delete files on s3" do
    original_config = MiniPaperclip.config
    MiniPaperclip.config.storage = :s3
    MiniPaperclip.config.s3_bucket_name = 'test'

    Aws.config[:stub_responses] = true
    Aws.config[:stub_responses] = {
      put_object: ->(context) {
        context.config[:stub_responses][:head_object] = { content_length: 1 }
        {}
      },
      delete_objects: ->(context) {
        fake_error = Class.new(Aws::S3::Errors::NotFound) do
          def initialize(*); end
        end
        context.config[:stub_responses][:head_object] = fake_error
        { deleted: context.params[:delete][:objects] }
      }
    }
    record.image = "data:image/png;base64,#{png_1x1_base64}"
    record.image_file_name = 'test.png'
    record.save!
    expect(record.image.storage.exists?(:original)).to eq(true)
    expect(record.image.storage.exists?(:medium)).to eq(true)
    record.destroy!
    expect(record.image.storage.exists?(:original)).to eq(false)
    expect(record.image.storage.exists?(:medium)).to eq(false)
  ensure
    original_config.each_pair { |k, v| MiniPaperclip.config[k] = v }
  end

  it "should invalid spoof media type url when dirty" do
    image_url = "http://www.example.log/a.png"
    file_path = "spec/paperclip.jpg"
    stub_request(:get, image_url)
      .with(headers: {'User-Agent' => 'Ruby'})
      .to_return(
        status: 200,
        body: File.read(file_path),
        headers: { 'Content-Length' => 0, 'Content-Type' => 'image/png' })
    record.image = image_url

    expect(record.image).to be_dirty
    expect(record).to be_invalid
    expect(record.errors[:image]).to be_present
  end

  it "should valid spoof media type url when dirty" do
    image_url = "http://www.example.log/a.png"
    file_path = "spec/paperclip.jpg"
    stub_request(:get, image_url)
      .with(headers: {'User-Agent' => 'Ruby'})
      .to_return(
        status: 200,
        body: File.read(file_path),
        headers: { 'Content-Length' => 0, 'Content-Type' => 'image/jpeg' })
    record.image = image_url

    expect(record.image).to be_dirty
    expect(record).to be_valid
  end

  it "should invalid spoof media type data-uri when dirty" do
    record.image = "data:image/jpeg;base64,#{png_1x1_base64}"

    expect(record.image).to be_dirty
    expect(record).to be_invalid
    expect(record.errors[:image]).to be_present
  end

  it "should valid spoof media type data-uri when dirty" do
    record.image = "data:image/png;base64,#{png_1x1_base64}"

    expect(record.image).to be_dirty
    expect(record).to be_valid
  end

  it "should valid when not dirty" do
    expect(record.image).to_not be_dirty
    expect(record).to be_valid
  end

  it "invalid content_type" do
    record.image = "data:text/plain;base64,a"
    expect(record).to be_invalid
  end

  it "invalid geometry" do
    record = ZeroRecord.new
    record.image = "data:image/png;base64,#{png_1x1_base64}"

    expect(record.image).to be_dirty
    expect(record).to be_invalid
    expect(record.errors.details[:image].first[:error]).to eq(:geometry)
  end
end

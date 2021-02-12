RSpec.describe MiniPaperclip do
  let(:record) { Record.new }

  describe "#config" do
    it "#keep_old_files = false" do
      old_file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
      record.image.config.keep_old_files = false
      record.image = old_file
      record.save!
      old_file_path = record.image.storage.file_path(:original)

      expect(File.exists?(old_file_path)).to eq(true)
      new_file = Rack::Test::UploadedFile.new "spec/opaopa.gif", 'image/gif'
      record.image = new_file
      record.save!
      expect(File.exists?(old_file_path)).to eq(false)
    end

    it "#keep_old_files = true" do
      old_file = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
      record.image.config.keep_old_files = true
      record.image = old_file
      record.save!
      old_file_path = record.image.storage.file_path(:original)

      expect(File.exists?(old_file_path)).to eq(true)
      new_file = Rack::Test::UploadedFile.new "spec/opaopa.gif", 'image/gif'
      record.image = new_file
      record.save!
      expect(File.exists?(old_file_path)).to eq(true)
    end

    it "#hash_data" do
      default_hash_data = MiniPaperclip.config.hash_data
      interpolated_hash_data = record.image.storage.interpolator.interpolate(default_hash_data, :original)
      expect(interpolated_hash_data).to eq('records/images//original/')

      record.id = 123
      record.image_updated_at = Time.at(0)
      interpolated_hash_data = record.image.storage.interpolator.interpolate(default_hash_data, :original)
      expect(interpolated_hash_data).to eq('records/images/123/original/0')
    end

    it "#interpolates" do
      template = ":class/:attachment/:hash/:id/:updated_at/:style.:extension"
      result = record.image.storage.interpolator.interpolate(template, :original)
      expect(result).to eq('records/images/25a80ba6aa8c48f17ea32fc7935fab633e807238///original.')

      record.id = 123
      record.image_file_name = 'test.png'
      record.image_updated_at = Time.at(0)
      result = record.image.storage.interpolator.interpolate(template, :original)
      expect(result).to eq('records/images/6860c24ea32461b288bf588906898042ae1aa54b/123/0/original.png')
    end
  end

  it "keeps last file with multiple assignments even if keep_old_files is false" do
    record.image.config.keep_old_files = false
    record.id = 123
    now = Time.at(123456) # for time freeze

    file1 = Rack::Test::UploadedFile.new "spec/paperclip.jpg", 'image/jpeg'
    file2 = Rack::Test::UploadedFile.new "spec/opaopa.gif", 'image/gif'

    record.image = file1
    record.image_updated_at = now # to freeze time
    record.image = file1
    record.image_updated_at = now # to freeze time
    record.save!

    path1 = Pathname.new(record.image.storage.file_path(:original))

    expect(path1).to be_exist

    record.image = file2
    record.image_updated_at = now # to freeze time
    record.image = file2
    record.image_updated_at = now # to freeze time
    record.save!

    path2 = Pathname.new(record.image.storage.file_path(:original))

    expect(path1).not_to be_exist
    expect(path2).to be_exist
  end
end

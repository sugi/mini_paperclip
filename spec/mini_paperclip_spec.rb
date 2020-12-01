RSpec.describe MiniPaperclip do
  let(:record) { Record.new }

  describe "#config" do
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
end

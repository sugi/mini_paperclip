RSpec.describe MiniPaperclip::Shoulda::Matchers::ValidateAttachmentPresenceMatcher do
  it "#matches? without validate_attachment presence: true" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentPresenceMatcher.new(:image)
    expect(matcher.matches?(Record.new)).to eq(false)
  end

  it "#matches? with validate_attachment presence: true" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentPresenceMatcher.new(:image)
    expect(matcher.matches?(PresenceRecord.new)).to eq(true)
  end
end

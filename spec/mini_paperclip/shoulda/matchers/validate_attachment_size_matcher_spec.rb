RSpec.describe MiniPaperclip::Shoulda::Matchers::ValidateAttachmentSizeMatcher do
  it "#matches? without validate_attachment presence: true" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentSizeMatcher.new(:image)
    matcher.less_than(1.megabytes)
    expect(matcher.matches?(Record.new)).to eq(false)
  end

  it "#matches? with validate_attachment presence: true" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentSizeMatcher.new(:image)
    matcher.less_than(1.megabytes)
    expect(matcher.matches?(PresenceRecord.new)).to eq(true)
  end
end

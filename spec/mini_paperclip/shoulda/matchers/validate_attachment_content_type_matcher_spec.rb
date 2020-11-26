RSpec.describe MiniPaperclip::Shoulda::Matchers::ValidateAttachmentContentTypeMatcher do
  it "#matches? without validate_attachment content_type:{}" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentContentTypeMatcher.new(:image)
    matcher.allowing('image/png').rejecting('text/plain')
    expect(matcher.matches?(Record)).to eq(false)
  end

  it "#matches? with validate_attachment content_type:{}" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentContentTypeMatcher.new(:image)
    matcher.allowing('image/png').rejecting('text/plain')
    expect(matcher.matches?(PresenceRecord)).to eq(true)
  end
end

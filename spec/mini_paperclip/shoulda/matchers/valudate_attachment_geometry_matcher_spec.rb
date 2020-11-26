RSpec.describe MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher do
  it "#matches? without validate_attachment geometry:{}" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher.new(:image)
    matcher.format(:jpg).width(less_than_or_equal_to: 1000).height(less_than_or_equal_to: 1000)
    expect(matcher.matches?(Record)).to eq(false)
  end

  it "#matches? with validate_attachment geometry:{}" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher.new(:image)
    matcher.format(:png).width(less_than_or_equal_to: 1000).height(less_than_or_equal_to: 1000)
    expect(matcher.matches?(PresenceRecord)).to eq(true)
  end

  it "#matches? failed when wrong width" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher.new(:image)
    matcher.format(:png).width(less_than_or_equal_to: -1).height(less_than_or_equal_to: 1000)
    expect(matcher.matches?(PresenceRecord)).to eq(false)
  end

  it "#matches? failed when wrong height" do
    matcher = MiniPaperclip::Shoulda::Matchers::ValidateAttachmentGeometryMatcher.new(:image)
    matcher.format(:png).width(less_than_or_equal_to: 1000).height(less_than_or_equal_to: -1)
    expect(matcher.matches?(PresenceRecord)).to eq(false)
  end
end

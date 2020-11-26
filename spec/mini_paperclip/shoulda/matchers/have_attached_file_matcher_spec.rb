RSpec.describe MiniPaperclip::Shoulda::Matchers::HaveAttachedFileMatcher do
  it "#matches? with Record" do
    matcher = MiniPaperclip::Shoulda::Matchers::HaveAttachedFileMatcher.new(:image)
    expect(matcher.matches?(Record)).to eq(true)
  end

  it "#matches? with NotExtend" do
    matcher = MiniPaperclip::Shoulda::Matchers::HaveAttachedFileMatcher.new(:image)
    expect(matcher.matches?(NotExtend)).to eq(false)
  end
end

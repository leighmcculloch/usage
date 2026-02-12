class Usage < Formula
  desc "Track time spent on the computer along with location"
  homepage "https://github.com/leighmcculloch/usage"
  head "https://github.com/leighmcculloch/usage.git", branch: "main"
  license "MIT"

  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app = prefix/"Usage.app"
    (app/"Contents/MacOS").mkpath
    (app/"Contents/Resources").mkpath
    cp ".build/release/Usage", app/"Contents/MacOS/"
    cp "Info.plist", app/"Contents/"
  end

  def caveats
    <<~EOS
      To start Usage:
        open "#{opt_prefix}/Usage.app"
    EOS
  end
end

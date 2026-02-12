class Usage < Formula
  desc "Track time spent on the computer along with location"
  homepage "https://github.com/leighmcculloch/usage"
  head "https://github.com/leighmcculloch/usage.git", branch: "main"
  license "MIT"

  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    system "swift", "scripts/generate-icon.swift"

    app = prefix/"Usage.app"
    (app/"Contents/MacOS").mkpath
    (app/"Contents/Resources").mkpath
    cp ".build/release/Usage", app/"Contents/MacOS/"
    cp "Info.plist", app/"Contents/"
    cp "build/AppIcon.icns", app/"Contents/Resources/"
  end

  def post_install
    user_apps = Pathname(Dir.home)/"Applications"
    user_apps.mkpath
    ln_sf prefix/"Usage.app", user_apps/"Usage.app"
  end

  def caveats
    <<~EOS
      Usage.app has been linked to ~/Applications.
    EOS
  end
end

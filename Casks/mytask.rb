cask "mytask" do
  version "0.1.83"
  name "myTask"
  desc "Personal GTD menu bar app"
  homepage "https://github.com/dimark57/mytask"

  on_arm do
    url "https://github.com/dimark57/mytask/releases/download/v#{version}/mytask-mac-v#{version}-source.zip"
    sha256 "6646981bd8796101d4564e9c0f61bf1ef6ddff5540ec3b03f8e9231357854e2b"
  end

  depends_on formula: "python@3.12"
  depends_on macos: ">= :sonoma"

  container type: :zip

  postflight do
    require "fileutils"

    dest = Pathname(Dir.home).join("Library/Application Support/mytask_mac")
    FileUtils.mkdir_p(dest)
    FileUtils.cp_r("#{staged_path}/.", dest, remove_destination: true)
    FileUtils.chmod("+x", dest.join("mytask-menubar"))

    bin = Pathname("#{HOMEBREW_PREFIX}/bin")
    FileUtils.ln_sf(dest.join("mytask-menubar"), bin.join("mytask-menubar"))
    FileUtils.ln_sf(dest.join("bin/mytask_mac"), bin.join("mytask_mac"))
  end

  uninstall delete: [
    "#{Dir.home}/Library/Application Support/mytask_mac",
    "#{HOMEBREW_PREFIX}/bin/mytask-menubar",
    "#{HOMEBREW_PREFIX}/bin/mytask_mac",
  ]

  caveats <<~EOS
    Run `mytask-menubar` to start the menu bar app.
    Local API: `mytask_mac` (requires `python@3.12` venv setup in Application Support on first use).
  EOS
end

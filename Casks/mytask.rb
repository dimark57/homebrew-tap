cask "mytask" do
  version "0.1.83"
  name "myTask"
  desc "Personal GTD menu bar app"
  homepage "https://github.com/dimark57/mytask"

  arch arm: true, intel: false

  # Private repo: browser download URL 404s; use GitHub release asset API.
  # Bump asset id when publishing a new Mac source zip release.
  url "https://api.github.com/repos/dimark57/mytask/releases/assets/570577139",
      header: [
        "Accept: application/octet-stream",
        "Authorization: bearer #{GitHub::API.credentials}",
      ]

  sha256 "6646981bd8796101d4564e9c0f61bf1ef6ddff5540ec3b03f8e9231357854e2b"

  depends_on formula: "python@3.12"
  depends_on macos: :sonoma

  container type: :zip

  postflight_steps do
    on_macos do
      run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "mytask-menubar"]
      run "/usr/bin/codesign", args: ["--force", "--sign", "-", "mytask-menubar"]
    end
    set_permissions "mytask-menubar", "0755"
    symlink "mytask-menubar",
            "{{HOMEBREW_PREFIX}}/bin/mytask-menubar",
            overwrite: true
    symlink "bin/mytask_mac",
            "{{HOMEBREW_PREFIX}}/bin/mytask_mac",
            overwrite: true
  end

  uninstall_postflight_steps do
    remove "{{HOMEBREW_PREFIX}}/bin/mytask-menubar"
    remove "{{HOMEBREW_PREFIX}}/bin/mytask_mac"
  end

  caveats <<~EOS
    Private GitHub repo: run `gh auth login` or set HOMEBREW_GITHUB_API_TOKEN.

    Run `mytask-menubar` to start the menu bar app.
  EOS
end

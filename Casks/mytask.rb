cask "mytask" do
  version "0.1.83"
  name "myTask"
  desc "Personal GTD menu bar app"
  homepage "https://github.com/dimark57/mytask"

  on_arm do
    asset_name = "mytask-mac-v#{version}-source.zip"

    url do
      release = GitHub.get_release("dimark57", "mytask", "v#{version}")
      asset = release.fetch("assets").find { |item| item["name"] == asset_name }
      odie "GitHub release asset #{asset_name} not found" if asset.nil?

      [
        asset.fetch("url"),
        header: [
          "Accept: application/octet-stream",
          "Authorization: bearer #{GitHub::API.credentials}",
        ],
      ]
    end

    sha256 "6646981bd8796101d4564e9c0f61bf1ef6ddff5540ec3b03f8e9231357854e2b"
  end

  depends_on formula: "python@3.12"
  depends_on macos: :sonoma

  container type: :zip

  postflight_steps do
    copy ".", "~/Library/Application Support/mytask_mac", recursive: true, overwrite: true
    set_permissions "~/Library/Application Support/mytask_mac/mytask-menubar", "0755"
    symlink "~/Library/Application Support/mytask_mac/mytask-menubar",
            "{{HOMEBREW_PREFIX}}/bin/mytask-menubar",
            overwrite: true
    symlink "~/Library/Application Support/mytask_mac/bin/mytask_mac",
            "{{HOMEBREW_PREFIX}}/bin/mytask_mac",
            overwrite: true
  end

  uninstall_postflight_steps do
    remove "~/Library/Application Support/mytask_mac", recursive: true
    remove "{{HOMEBREW_PREFIX}}/bin/mytask-menubar"
    remove "{{HOMEBREW_PREFIX}}/bin/mytask_mac"
  end

  caveats <<~EOS
    Private GitHub repo: run `gh auth login` or set HOMEBREW_GITHUB_API_TOKEN.

    Run `mytask-menubar` to start the menu bar app.
  EOS
end

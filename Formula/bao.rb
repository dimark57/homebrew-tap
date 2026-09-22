require_relative "../lib/github_release_download_strategy"

class Bao < Formula
  desc "OpenBao secrets CLI — import/export app .env files (NAS / Docker)"
  homepage "https://github.com/dimark57/mySecrets"
  version "0.1.0"
  license "MIT"

  # Private repo: export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"
  # Release asset (update asset id when re-uploading mySecrets-x.y.z.tar.gz)
  url "https://api.github.com/repos/dimark57/mySecrets/releases/assets/580693731",
      using: GitHubReleaseDownloadStrategy
  sha256 "ea28970860a3ed053b6502c0bc7c0410f7cfbd06b86af0c97922ad225d07d7f6"

  depends_on "docker" if OS.linux?
  conflicts_with "openbao"

  def install
    share = libexec/"mySecrets"
    share.mkpath
    system "tar", "-xzf", cached_download.to_s, "-C", share.to_s

    chmod 0755, share/"bao.sh"
    Pathname.glob("#{share}/scripts/*.sh").each { |f| chmod 0755, f }
    chmod 0755, share/"cli/bin/bao"
    chmod 0755, share/"cli/install.sh"

    (bin/"bao-secrets").write <<~SH
      #!/bin/bash
      if [[ -z "${BAO_STACK:-}" && -x "/srv/nas/stacks/openbao/bao.sh" ]]; then
        export BAO_STACK="/srv/nas/stacks/openbao"
      elif [[ -z "${BAO_STACK:-}" ]]; then
        export BAO_STACK="#{share}"
      fi
      exec "#{share}/cli/bin/bao" "$@"
    SH
  end

  def caveats
    <<~EOS
      Installed as `bao-secrets` (OpenBao upstream owns `bao` on Mac).
      NAS: `sudo bao-secrets install --confirm` → optional `sudo ln -sf $(brew --prefix)/bin/bao-secrets /usr/local/bin/bao`
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bao-secrets version")
  end
end

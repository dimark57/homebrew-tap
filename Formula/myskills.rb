# typed: false
# frozen_string_literal: true

require_relative "../lib/github_release_download_strategy"

class Myskills < Formula
  desc "mySkills installer — materialize skills into Cursor, OpenCode, Codex, Claude Code"
  homepage "https://github.com/dimark57/mySkills"
  version "0.1.1"
  license "MIT"

  # Private repo — same as dimark57/tap/bao.rb:
  #   export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"
  # Bump asset id when re-uploading myskills-x.y.z.tar.gz on GitHub Release v0.1.1.
  url "https://api.github.com/repos/dimark57/mySkills/releases/assets/581219812",
      using: GitHubReleaseDownloadStrategy
  sha256 "574858f56d64ce8469e0c5af3b2b82b29613b2dd7f134da33f246cc9b67b1d41"

  depends_on "python@3.13"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz"
    sha256 "d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e"
  end

  def install
    venv = libexec/"venv"
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", venv
    resource("pyyaml").stage { system venv/"bin/pip", "install", "PyYAML==6.0.2" }

    src = package_source_root
    share = prefix/"share/myskills"
    share.install src/"skills"
    share.install src/"catalog"
    share.install src/"platform"
    libexec.install src/"deploy/bootstrap/myskills_cli.py"
    (bin/"myskills").write <<~EOS
      #!/bin/bash
      export MY_SKILLS_PREFIX="#{share}"
      exec "#{venv}/bin/python3.13" "#{libexec}/myskills_cli.py" "$@"
    EOS
    chmod 0755, bin/"myskills"
  end

  def package_source_root
    cand = buildpath/"mySkills-#{version}"
    return cand if cand.directory?

    return buildpath if (buildpath/"skills").directory?

    odie "myskills: expected mySkills-#{version}/ or skills/ in archive"
  end

  def postinstall
    if ENV["MY_SKILLS_AUTO_APPLY"] == "0"
      ohai "myskills: автоматическое обновление IDE отключено."
      puts "  После каждого brew upgrade: myskills apply --confirm && myskills doctor"
      return
    end
    host = File.expand_path("~/.config/myskills/host.yaml")
    unless File.file?(host)
      ohai "myskills установлен в #{prefix}/share/myskills"
      puts "  Сделайте (один раз): myskills discover && myskills apply --confirm"
      puts "  Подробнее: docs/user/myskills-install.md"
      return
    end
    system bin/"myskills", "plan"
    system bin/"myskills", "apply", "--confirm"
    doctor = system bin/"myskills", "doctor", "--full"
    return if doctor

    odie <<~MSG
      myskills: установка не завершена.
        myskills apply --confirm && myskills doctor
        docs/user/myskills-install.md §3
    MSG
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/myskills version")
  end
end

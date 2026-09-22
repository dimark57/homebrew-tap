# typed: false
# frozen_string_literal: true

class Myskills < Formula
  desc "mySkills installer — materialize skills into Cursor, OpenCode, Codex, Claude Code"
  homepage "https://github.com/dimark57/mySkills"
  version "0.1.1"
  license "MIT"

  # Private repo: set HOMEBREW_GITHUB_API_TOKEN before brew install/fetch (uses GitHub API, not git clone).
  url "https://github.com/dimark57/mySkills/archive/refs/tags/v#{version}.tar.gz"
  sha256 "5b26ea3f22d02cb59695afda9c7e72ed71e685fce6546d2d309f9dca46e85835"

  depends_on "python@3.13"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz"
    sha256 "d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e"
  end

  def install
    venv = libexec/"venv"
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", venv
    resource("pyyaml").stage { system venv/"bin/pip", "install", "PyYAML==6.0.2" }

    share = prefix/"share/myskills"
    share.install "skills"
    share.install "catalog"
    share.install "platform"
    libexec.install "deploy/bootstrap/myskills_cli.py"
    (bin/"myskills").write <<~EOS
      #!/bin/bash
      export MY_SKILLS_PREFIX="#{share}"
      exec "#{venv}/bin/python3.13" "#{libexec}/myskills_cli.py" "$@"
    EOS
    chmod 0755, bin/"myskills"
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

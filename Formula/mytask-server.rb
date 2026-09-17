class MytaskServer < Formula
  desc "Docker lifecycle CLI for the myTask server"
  homepage "https://github.com/dimark57/mytask"
  url "https://github.com/dimark57/mytask/archive/refs/tags/v0.1.83.tar.gz"
  version "0.1.83"
  sha256 "23b794c0b2efef2d9651e81dcc86431d11b77089b2ef4d18ee0e9f0bc6c4be37"
  license "MIT"

  depends_on "docker" if OS.linux?
  depends_on cask: "docker" if OS.mac?

  def install
    server_root = buildpath/"mytask-#{version}/mytask-server"
    odie "mytask-server directory missing in source archive" unless server_root.directory?

    share = libexec/"mytask-server"
    share.install server_root/"bin"
    share.install server_root/"compose"
    share.install server_root/"lib"
    share.install server_root/"scripts"
    share.install server_root/"config.json"
    share.install server_root/"openbao" if (server_root/"openbao").directory?

    (bin/"mytask-server").write <<~SH
      #!/bin/bash
      exec "#{share}/bin/mytask-server" "$@"
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mytask-server version")
  end
end

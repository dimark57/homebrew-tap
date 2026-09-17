class Myinstall < Formula
  desc "Host-side application installer and runtime lifecycle manager"
  homepage "https://github.com/dimark57/myinstall"
  version "0.3.36"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/dimark57/myinstall/releases/download/v#{version}/myinstall-v#{version}-darwin-arm64"
      sha256 "b73bad3662585df5911f980d0898c247aebb4276c4b62eecc988d0de7928a2ef"
    else
      url "https://github.com/dimark57/myinstall/releases/download/v#{version}/myinstall-v#{version}-darwin-amd64"
      sha256 "b73bad3662585df5911f980d0898c247aebb4276c4b62eecc988d0de7928a2ef"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/dimark57/myinstall/releases/download/v#{version}/myinstall-v#{version}-linux-arm64"
      sha256 "8ff40c2ae182f4079d03e88e4e8c62408cf7a516b9e6b7256dd46cabc6f5758b"
    else
      url "https://github.com/dimark57/myinstall/releases/download/v#{version}/myinstall-v#{version}-linux-amd64"
      sha256 "8ff40c2ae182f4079d03e88e4e8c62408cf7a516b9e6b7256dd46cabc6f5758b"
    end
  end

  depends_on "python@3.12"

  def install
    artifact = Dir["myinstall-v#{version}-*"].fetch(0)
    libexec.install artifact
    artifact_path = libexec.join(File.basename(artifact))
    python = Formula["python@3.12"].opt_bin.join("python3")

    (bin/"myinstall").write <<~SH
      #!/bin/sh
      exec "#{python}" "#{artifact_path}" "$@"
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/myinstall --version")
  end
end

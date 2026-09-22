# Private GitHub release assets (requires HOMEBREW_GITHUB_API_TOKEN).
# Canonical copy lives in dimark57/homebrew-tap/lib/ — keep in sync on release.
class GitHubReleaseDownloadStrategy < CurlDownloadStrategy
  def curl_args(*extra_args, **extra_kwargs)
    args = super
    token = ENV["HOMEBREW_GITHUB_API_TOKEN"].to_s.strip
    return args if token.empty?

    args += ["-H", "Authorization: Bearer #{token}"]
    args += ["-H", "Accept: application/octet-stream"] if url.include?("api.github.com/repos/")
    args
  end
end

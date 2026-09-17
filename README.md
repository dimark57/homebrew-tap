# dimark57 Homebrew tap

Homebrew packages published by dimark57.

## myTask server (NAS / Docker)

```bash
export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"   # private repo tarball
brew tap dimark57/tap
brew install dimark57/tap/mytask-server
```

Installs `mytask-server` from [dimark57/mytask](https://github.com/dimark57/mytask) release source.
Secrets on NAS: `/srv/nas/stacks/openbao/bao.sh mytask apply prod`.

## myTask Mac menu bar

Private repo — Homebrew needs a GitHub token to download release assets:

```bash
export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"   # or classic PAT with repo scope
brew tap dimark57/tap
brew install --cask dimark57/tap/mytask
mytask-menubar
```

No parentheses in the command. Correct: `brew install --cask dimark57/tap/mytask`

## Legacy

`myinstall` remains in the tap for older workflows; new installs should use `mytask-server`.

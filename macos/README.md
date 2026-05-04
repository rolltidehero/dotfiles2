# macOS Setup

## Changelog

### Deprecated (kept for historical reference)

| App | Replaced by | Reason |
|-----|-------------|--------|
| Alfred | **Raycast** | Raycast is faster, free, and has a better plugin ecosystem |
| iTerm2 | **Ghostty** | Ghostty has better performance and a native feel |
| Ice (menu bar manager) | **Native macOS Tahoe** | macOS Tahoe has built-in menu bar management |

Config files for Alfred and Ice are kept in this repo for historical reference only. No new updates will be made to them.

---

## Install

```bash
# Full install (personal or work)
./bootstrap.sh personal-mac
./bootstrap.sh work-mac

# macOS defaults only (no other dependencies)
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/macos/mac-defaults.sh | bash
```

---

## Post-Install Checklist

Manual steps required after running the installer:

- [ ] **Bitwarden** — install from the Mac App Store (required for Touch ID support in the browser extension; not available via Homebrew cask)
- [ ] **Raycast** — sign in and restore config from Raycast Cloud: Raycast → Settings → Advanced → Import
- [ ] **Hammerspoon** — open Hammerspoon.app and grant Accessibility permission in System Settings
- [ ] **Karabiner-Elements** — open and grant Input Monitoring permission in System Settings
- [ ] **GPG signing** (personal Mac only) — re-enable after git config install:
  ```bash
  git config --global commit.gpgsign true
  git config --global gpg.program /opt/homebrew/bin/gpg
  git config --global user.signingkey <YOUR_KEY_ID>
  ```

---

## Brewfiles

| File | Purpose |
|------|---------|
| `Brewfile` | Base essentials installed on **every** Mac (run first) |
| `Brewfile.personal` | Personal Mac extras: ML/data science tools, personal apps |
| `Brewfile.work` | Work Mac extras: work dev tools, Slack, work apps |

Run order:
```bash
brew bundle --file=macos/Brewfile            # always
brew bundle --file=macos/Brewfile.personal   # personal Mac
# or
brew bundle --file=macos/Brewfile.work       # work Mac
```

---

## Hammerspoon

`hammerspoon/init.lua` is installed for both personal and work Macs (via `macos/install.sh`, which runs `hammerspoon/install.sh`).

**Standalone (one line, no clone):**

```bash
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/macos/hammerspoon/install.sh | bash
```

Spoons installed automatically by `hammerspoon/install.sh`:
- [ReloadConfiguration](https://www.hammerspoon.org/Spoons/ReloadConfiguration.html) — auto-reloads config on file change

To install additional Spoons manually, download from [hammerspoon.org/Spoons](https://www.hammerspoon.org/Spoons/) and unzip to `~/.hammerspoon/Spoons/`.

---

## Custom Keyboard Shortcuts

- Select the previous input source: `Meta + i`
- Save picture of selected area as a file: `Meta + S`
- `Emoji & Symbols`: `CMD+.`

---

## Remarks

- Install Bitwarden from the App Store for Touch ID support in the browser extension.
- Install Raycast from the Brewfile; restore extensions and config from Raycast Cloud.
- `hammerspoon/base-init.lua` is archived for historical reference.

## Interesting Apps

- [Hook – Links beat searching](https://hookproductivity.com/) — link related content together
- [PopClip for Mac](https://pilotmoon.com/popclip/) — quick actions on highlighted text
- [Rocket – the best emoji app for Mac](https://matthewpalmer.net/rocket/) — fast emoji input
- [TopNotch for macOS](https://topnotch.app/) — hide the Mac notch

## Signing Git Commits

To set up GitHub with a GPG key and private email, follow:
[Github "Verified" commits using GPG key with private email](https://gist.github.com/nitrocode/bc62b6e86d1bd8c3acf9cb83caab3883)

## References

- [macos-defaults.com](https://macos-defaults.com/)
- [Where are keyboard shortcuts stored?](https://apple.stackexchange.com/questions/87619/where-are-keyboard-shortcuts-stored-for-backup-and-sync-purposes)

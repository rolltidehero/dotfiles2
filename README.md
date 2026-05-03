# dotfiles

> Modular dotfiles for macOS · Linux · EC2 · HPC · Android

---

## Quick Start

### Full install — clone and run once

```bash
git clone https://github.com/davzoku/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh <machine-type>
```

| Machine type     | Description                              |
| ---------------- | ---------------------------------------- |
| `personal-mac`   | macOS — full dev + personal toolset      |
| `work-mac`       | macOS — development + work communication |
| `personal-linux` | Linux — Ubuntu                           |
| `cloud`          | Cloud Linux instances (EC2, GCP, Azure…) |
| `hpc`            | HPC cluster (Slurm/PBS setups)           |

### One-liner install — no clone needed

#### Ubuntu

Install `nvim`, `tmux`, `fzf` and `bat` on a fresh Ubuntu instance in one step without sudo:

```bash
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ubuntu/install-tools.sh | bash
```

- **tmux** — via apt
- **fzf** — via git clone to `~/.fzf`, linked to `~/.local/bin/fzf`
- **nvim** — latest stable AppImage to `~/.local/bin/nvim`

Idempotent — skips anything already installed. After running, apply your dotfiles with the curl commands above.

---

#### SSH

##### Add your public key to a remote instance

Run on the remote machine after spinning up a new instance. Idempotent — skips if your key is already present.

```bash
# Prompted interactively
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ssh/add-pubkey.sh | bash

# Or pass the key directly (useful in startup scripts)
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/ssh/add-pubkey.sh | bash -s -- "ssh-ed25519 AAAA..."
```

##### Add a host entry to your local SSH config

Run locally after provisioning a new instance. Idempotent — skips if the host alias already exists.

```bash
# Interactive — prompts for any missing values
bash ssh/add-host.sh

# Or pass all args directly:
#   bash ssh/add-host.sh <Host> <HostName> <User> [IdentityFile]
bash ssh/add-host.sh host 1.1.1.1 ubuntu ~/.ssh/private-key
```

Produces an entry like:

```
Host host
    HostName 1.1.1.1
    User ubuntu
    ServerAliveInterval 120
    IdentityFile ~/.ssh/private-key
```

---

```bash
BASE="https://raw.githubusercontent.com/davzoku/dotfiles/master"
```

---

Pick what you need:

**Shell foundation** — install these to create fzf vars, and personal aliases

```bash
curl -fsSL $BASE/shell/install.sh | bash   # ~/.shell_common.sh (PATH, fzf opts, exports)
curl -fsSL $BASE/alias/install.sh | bash   # ~/.alias
```

**Editor & multiplexer**

```bash
curl -fsSL $BASE/vim/install.sh  | bash   # ~/.vimrc
curl -fsSL $BASE/nvim/install.sh | bash   # ~/.config/nvim/  (clone preferred)
curl -fsSL $BASE/tmux/install.sh | bash   # ~/.tmux.conf
```

**Shell config**

```bash
curl -fsSL $BASE/zsh/install.sh  | bash   # ~/.zshrc  (zsh + oh-my-zsh)
curl -fsSL $BASE/git/install.sh  | bash   # ~/.gitconfig
```

**macOS**

```bash
curl -fsSL $BASE/ghostty/install.sh        | bash   # ~/.config/ghostty/config
curl -fsSL $BASE/macos/mac-defaults.sh     | bash   # dock speed, hidden files, etc.
```

**Linux / remote — bash with machine variant**

```bash
curl -fsSL $BASE/bash/install.sh | bash -s -- linux   # personal Linux
curl -fsSL $BASE/bash/install.sh | bash -s -- cloud     # EC2, GCP, Azure…
curl -fsSL $BASE/bash/install.sh | bash -s -- hpc     # HPC cluster
```

**Quick EC2 / VM setup** — shell + aliases + vim + tmux + git + bash

```bash
BASE="https://raw.githubusercontent.com/davzoku/dotfiles/master"
for c in shell alias vim tmux git; do
  curl -fsSL $BASE/$c/install.sh | bash
done
curl -fsSL $BASE/bash/install.sh | bash -s -- cloud
```

---

## What's Installed Where

| Component            | personal-mac | work-mac | personal-linux | cloud | hpc |
| -------------------- | :----------: | :------: | :------------: | :---: | :-: |
| shell (fzf, exports) |      ✓       |    ✓     |       ✓        |   ✓   |  ✓  |
| alias                |      ✓       |    ✓     |       ✓        |   ✓   |  ✓  |
| zsh                  |      ✓       |    ✓     |       —        |   —   |  —  |
| bash                 |      —       |    —     |       ✓        |   ✓   |  ✓  |
| git                  |      ✓       |    ✓     |       ✓        |   ✓   |  ✓  |
| vim                  |      ✓       |    ✓     |       ✓        |   ✓   |  ✓  |
| tmux                 |      ✓       |    ✓     |       ✓        |   ✓   |  ✓  |
| nvim                 |      ✓       |    ✓     |       ✓        |   —   |  —  |
| modern CLI tools     |   Brewfile   | Brewfile |       ✓        |   —   |  —  |
| ghostty              |      ✓       |    —     |       —        |   —   |  —  |
| macos                |      ✓       |    ✓     |       —        |   —   |  —  |

Modern CLI tools: `dust` · `bat` · `eza` · `fd` · `ripgrep` · `git-delta` · `zoxide` · `bottom` · `hyperfine`

---

## Machine-local Overrides

Create `~/.shell_local` for anything not tracked in this repo. It is sourced automatically at the end of `~/.shell_common.sh`.

```bash
# ~/.shell_local on HPC
module load cuda/12.0
export SCRATCH=/scratch/$USER

# ~/.shell_local on work-mac
export WORK_AWS_PROFILE=my-profile
```

---

## macOS

Three Brewfiles — always run the base first:

```bash
brew bundle --file=macos/Brewfile            # essentials: Ghostty, VSCode, Raycast, Hammerspoon…
brew bundle --file=macos/Brewfile.personal   # personal: ML tools, Discord, Figma, Steam…
brew bundle --file=macos/Brewfile.work       # work: Slack, AWS CLI, Postman…
```

See [`macos/README.md`](macos/README.md) for the post-install checklist and app changelog.

---

## Other

**ble.sh** — readline replacement for bash (personal Linux)

```bash
curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
  | tar xJf - -C ~/.local/share/blesh --strip-components=1
```

**Claude Code settings**

```bash
curl -fsSL https://raw.githubusercontent.com/davzoku/dotfiles/master/.claude/replace_local_claude_settings.sh | bash
```

**Android / Termux** — see [`android/README.md`](android/README.md)

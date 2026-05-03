#!/usr/bin/env bash
# Shared environment config — sourced by both zsh and bash.
# Aliases live in ~/.alias (alias/install.sh). Machine-local overrides go in ~/.shell_local.

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export HISTSIZE=10000
export HISTFILESIZE=20000

# fzf options — apply to all shells and machines
export FZF_DEFAULT_OPTS='--height 40% --popup bottom,40% --layout reverse --border top'

[[ -f ~/.shell_local ]] && source ~/.shell_local

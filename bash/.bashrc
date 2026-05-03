# ~/.bashrc — base bash config

# Source shared environment (PATH, EDITOR, exports)
[[ -f ~/.shell_common.sh ]] && source ~/.shell_common.sh

# Source shared aliases
[[ -f ~/.alias ]] && source ~/.alias

# Source machine-specific variant if present
[[ -f ~/.bashrc.variant ]] && source ~/.bashrc.variant

# Source machine-local overrides if present (not tracked in repo)
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# --- Prompt ---
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

# --- History ---
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# --- Bash completion ---
if [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# --- fzf ---
command -v fzf &>/dev/null && source <(fzf --bash)

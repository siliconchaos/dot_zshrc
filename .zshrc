# Imporoved SilentCastle zsh environment
# Version 0.2.0
#

# Source machine-agnostic defaults first (environment variables, PATH tweaks, etc.)
if [[ -f "$HOME/.shell_defaults" ]]; then
    source "$HOME/.shell_defaults"
fi

# Zinit Installation & Plugin Management
# --------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if ! command -v git &> /dev/null; then
    echo "[SilentCastle zsh] git is required to manage zinit; exiting." >&2
    return 1 2>/dev/null || exit 1
fi
# install zinit if not already installed
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    if ! git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
        echo "[SilentCastle zsh] failed to clone zinit repository; exiting." >&2
        return 1 2>/dev/null || exit 1
    fi
fi
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    echo "[SilentCastle zsh] zinit installation incomplete; exiting." >&2
    return 1 2>/dev/null || exit 1
fi
source "$ZINIT_HOME/zinit.zsh"

# History configuration
# ---------------------
# History
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt extendedhistory          # Save timestamp of command
setopt appendhistory            # Append history to the history file
setopt sharehistory             # Share history between all sessions
setopt hist_ignore_space        # Ignore commands that start with a space
setopt hist_ignore_all_dups     # Delete old recorded duplicates
setopt hist_save_no_dups        # Do not save duplicates
setopt hist_ignore_dups         # Ignore duplicates
setopt hist_find_no_dups        # Do not display duplicates
setopt hist_expire_dups_first   # Expire duplicates first when trimming history


# Add zsh plugins
# ---------------

zinit load zsh-users/zsh-syntax-highlighting
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-completions
zinit load chrissicool/zsh-256color
zinit load zsh-users/zsh-history-substring-search
if command -v eza &> /dev/null; then
    zinit load z-shell/zsh-eza
    export _EZA_PARAMS=('--git' '--icons' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all')
#    export AUTOCD=1  # Enable auto list directories on cd
fi

# Add snippets
# ------------
if command -v aws &> /dev/null; then
    zinit snippet OMZP::aws
fi
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::vi-mode
zinit snippet OMZP::extract

# Load completions
# ----------------
autoload -Uz compinit && compinit
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no


# Begin custom configurations
# ---------------------------

if [[ -z "$EDITOR" ]]; then
    for _editor_candidate in hx nvim vim nano vi; do
        if command -v "$_editor_candidate" &> /dev/null; then
            EDITOR="$_editor_candidate"
            break
        fi
    done
fi
EDITOR=${EDITOR:-vi}
export EDITOR
unset _editor_candidate
VI_MODE_SET_CURSOR=true # set cursor to vi-mode plugin

# key bindings
bindkey "^[[3~" delete-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# Edit line in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Load starshipt prompt
if command -v starship &> /dev/null && [[ ${ENABLE_STARSHIP:-true} == true ]]; then
    # suppress starship warning
    export STARSHIP_LOG="error"
    eval "$(starship init zsh)"
    unset ENABLE_STARSHIP
fi

# fzf integration
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
    zinit load Aloxaf/fzf-tab
fi

if command -v fastfetch &> /dev/null && [[ ${ENABLE_FASTFETCH:-false} == true ]]; then
    fastfetch
    unset ENABLE_FASTFETCH
fi

# Source host-specific or temporary overrides last; great for local tweaks not shared via git
if [[ -f "$HOME/.shell_post" ]]; then
    source "$HOME/.shell_post"
fi

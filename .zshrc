# Imporoved SilentCastle zsh environment
# Version 0.1.0
#

# Source shell defaults if available
if [[ -f ~/.shell_defaults ]]; then
    source ~/.shell_defaults
fi

# Zinit Installation & Plugin Management
# --------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
# install zinit if not already installed
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# History configuration
# ---------------------
# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
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

# zinit load z-shell/F-Sy-H
zinit load zsh-users/zsh-syntax-highlighting
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-completions
zinit load chrissicool/zsh-256color
zinit load zsh-users/zsh-history-substring-search

# Add snippets
# ------------

zinit snippet OMZP::aws
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

EDITOR=${EDITOR:-nvim}
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

# Load starshipt prompt
if command -v starship &> /dev/null && [[ $ENABLE_STARSHIP == true ]]; then
    # suppress starship warning
    export STARSHIP_LOG="error"
    eval "$(starship init zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v fastfetch &> /dev/null; then
    fastfetch
fi


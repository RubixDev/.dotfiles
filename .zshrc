if [ -n "$DESKTOP_SESSION" ] && command -v gnome-keyring-daemon > /dev/null; then
  eval "$(gnome-keyring-daemon --start &> /dev/null)"
  export SSH_AUTH_SOCK
fi

if command -v uname > /dev/null && [ "$(uname -o)" = "Android" ]; then
    is_android=true
else
    is_android=false
fi

source ~/.config/env
export HISTFILE="$XDG_STATE_HOME/zsh/history"

if [ "$is_android " = true ] && [ -z "$SSH_TTY" ]; then
    ZSH_THEME="zish"
fi
DISABLE_MAGIC_FUNCTIONS="true"

plugins=(
  git
  sudo
  zsh-autosuggestions
  history-substring-search
  zsh-syntax-highlighting
  zsh-vi-mode
)

# autojump
[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh

source $ZSH/oh-my-zsh.sh
_comp_options+=(globdots) # Show hidden files in tab completion
zstyle ':completion:*' special-dirs false # but not . and ..

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Ctrl+K for escape
ZVM_VI_ESCAPE_BINDKEY='^K'
ZVM_VI_INSERT_ESCAPE_BINDKEY='^K'
ZVM_VI_VISUAL_ESCAPE_BINDKEY='^K'
ZVM_VI_OPPEND_ESCAPE_BINDKEY='^K'

# Other Vim keybinds
bindkey -a -s 'H' '^'
bindkey -a -s 'L' '$'

ZSH_HIGHLIGHT_STYLES[arg0]=fg=4
ZSH_HIGHLIGHT_STYLES[command]=fg=4
ZSH_HIGHLIGHT_STYLES[alias]=fg=4
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=4
ZSH_HIGHLIGHT_STYLES[precommand]=fg=4,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=6,bold
ZSH_HIGHLIGHT_STYLES[default]=fg=12
ZSH_HIGHLIGHT_STYLES[path]=fg=12
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=5
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=208,bold
ZSH_HIGHLIGHT_STYLES[assign]=fg=14

setopt extendedglob
source ~/.config/aliasrc

bindkey -v
bindkey -s '^o' '^ujo\n'

echo
# run pfetch-rs
pfetch

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/p10k.toml)"

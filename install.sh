#!/bin/bash

install_file () {
    mkdir -p "$HOME/$(dirname "$1")"
    [[ ! -f ~/"$1" ]] || mv ~/"$1" ~/"$1".old
    [[ ! -L ~/"$1" ]] || rm ~/"$1"
    ln -s "$PWD/$1" "$HOME/$1"
}

# Install powerlevel10k theme, if not present yet
[[ -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]] || {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
}

install_file .zshrc
install_file .p10k.zsh
install_file .config/.aliasrc.zsh
install_file .tmux.conf
install_file .config/terminator/config

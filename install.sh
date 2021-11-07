#!/bin/bash

install_file () {
    [[ ! -f ~/"$1" ]] || mv ~/"$1" ~/"$1".old
    [[ ! -L ~/"$1" ]] || rm ~/"$1"
    ln -s "$PWD/$(basename "$1")" ~/"$(dirname "$1")"/
}

# Install powerlevel10k theme, if not present yet
[[ -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]] || {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
}

install_file .zshrc
install_file .p10.zsh
install_file .config/.aliasrc
install_file .tmux.conf

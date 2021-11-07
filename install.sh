#!/bin/bash

[[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10ka ]] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
[[ ! -f ~/.zshrc ]] || mv ~/.zshrc ~/.zshrc.old
[[ ! -L ~/.zshrc ]] || rm ~/.zshrc
ln -s "$PWD/.zshrc" ~/

[[ ! -f ~/.p10k.zsh ]] || mv ~/.p10k.zsh ~/.p10k.zsh.old
[[ ! -L ~/.p10k.zsh ]] || rm ~/.p10k.zsh
ln -s "$PWD/.p10k.zsh" ~/

[[ ! -f ~/.config/.aliasrc ]] || mv ~/.config/.aliasrc ~/.config/.aliasrc.old
[[ ! -L ~/.config/.aliasrc ]] || rm ~/.config/.aliasrc
ln -s "$PWD/.aliasrc" ~/.config/

#!/bin/sh

[ "$(basename "$PWD")" = .dotfiles ] || {
    echo "Please run this script from your .dotfiles project root"
    exit 1
}

########## Dependency Installation ##########
# TODO: ask for installation

if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    is_desktop=true
fi

install_android () {
    true
}

install_arch () {
    if command -v paru > /dev/null; then
        aur=paru
    elif command -v yay > /dev/null; then
        aur=yay
    else
        echo "Neither paru nor yay is installed on your system, but required for AUR packages"
        exit 1
    fi

    command -v rustup > /dev/null && has_rustup=true

    $aur -Sy --needed fd ripgrep proximity-sort neovim zsh rustup fzf git curl wget shellcheck \
        pfetch neovim-plug nodejs yarn || exit 2
    [ "$is_desktop" = true ] && $aur -S --needed polybar sway-launcher-desktop bspwm sxhkd dunst \
        alacritty picom nitrogen numlockx slock neovim-remote ttf-meslo-nerd-font-powerlevel10k

    [ "$has_rustup" = true ] || rustup default stable
}

install_debian () {
    sudo apt install zsh fzf git curl wget shellcheck nodejs npm || exit 2
    [ "$is_desktop" = true ] && sudo apt install bspwm sxhkd polybar dunst picom nitrogen numlockx \
        suckless-tools

    sudo npm install -g yarn || exit 2

    if ! command -v rustup > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        rustup default stable
    fi

    cargo install fd-find ripgrep proximity-sort || exit 2
    [ "$is_desktop" = true ] && cargo install alacritty

    if ! command -v nvim > /dev/null; then
        wget 'https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb' || exit 2
        sudo apt install ./nvim-linux64.deb
        rm ./nvim-linux64.deb
    fi

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if ! command -v pfetch > /dev/null; then
        wget 'https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch'
        sudo cp ./pfetch /usr/local/bin/pfetch
        sudo chmod +x /usr/local/bin/pfetch
        rm ./pfetch
    fi
}

if command -v uname > /dev/null && [ "$(uname -o)" = "Android" ]; then
    install_android
else
    . /etc/os-release
    case "$ID" in
        "arch") install_arch ;;
        "debian") install_debian ;;
        *)
            case "$ID_LIKE" in
                "arch") install_arch ;;
                "debian") install_debian ;;
                *)
                    echo "Automatic dependency installation is not supported for this distribution"
                    exit 3
                    ;;
            esac
            ;;
    esac
fi

# oh-my-zsh
[ -e ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
[ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
[ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ] || git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
[ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
[ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode" ] || git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"

########### dotfiles Installation ###########
install_file () {
    mkdir -p "$HOME/$(dirname "$1")"
    [ ! -L ~/"$1" ] || rm ~/"$1"
    [ ! -e ~/"$1" ] || mv ~/"$1" ~/"$1".old
    ln -s "$PWD/$1" "$HOME/$1"
}

# Install powerlevel10k theme, if not yet present
[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ] || {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
}

# Uninstall SpaceVim if present
[ -e ~/.SpaceVim ] && curl -sLf https://spacevim.org/install.sh | bash -s -- --uninstall

install_file .zshrc
install_file .p10k.zsh
install_file .config/.aliasrc.zsh
install_file .tmux.conf
install_file .config/terminator/config
install_file .config/alacritty/alacritty.yml
install_file .config/i3/config
install_file .config/nvim/init.vim
install_file .config/paru/paru.conf
install_file .config/bspwm/bspwmrc
install_file .config/sxhkd/sxhkdrc
install_file .config/dunst/dunstrc
install_file .config/picom.conf
install_file .config/polybar/config.ini


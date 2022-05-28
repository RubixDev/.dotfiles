#!/bin/bash

[ "$(basename "$PWD")" = .dotfiles ] || {
    echo "Please run this script from your .dotfiles project root"
    exit 1
}

prompt () {
    read -p "$1 [Y/n] " -r choice
    case "$choice" in
        [Yy][Ee][Ss]|[Yy]|'') return 0 ;;
        *) return 1 ;;
    esac
}

########## Dependency Installation ##########
prompt "Install desktop configurations?" && is_desktop=true

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

    $aur -Sy --needed --noconfirm fd ripgrep neovim zsh rustup fzf git curl wget shellcheck \
        pfetch neovim-plug nodejs yarn || exit 2
    rustup default > /dev/null || { rustup default stable || exit 2; }
    $aur -S --needed --noconfirm proximity-sort || exit 2
    [ "$is_desktop" = true ] && $aur -S --needed --noconfirm polybar sway-launcher-desktop bspwm sxhkd dunst \
        alacritty picom nitrogen numlockx slock neovim-remote ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono
}

install_debian () {
    sudo apt update
    sudo apt install -y zsh fzf git curl wget shellcheck nodejs npm || exit 2
    [ "$is_desktop" = true ] && sudo apt install -y bspwm sxhkd polybar dunst picom nitrogen \
        numlockx suckless-tools cmake pkg-config libfreetype6-dev libfontconfig1-dev \
        libxcb-xfixes0-dev libxkbcommon-dev python3

    sudo npm install -g yarn || exit 2

    if ! command -v rustup > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        exec "$SHELL"
    fi

    rustup default > /dev/null || { rustup default stable || exit 2; }
    cargo install fd-find ripgrep proximity-sort || exit 2

    if [ "$is_desktop" = true ]; then
        git clone https://github.com/alacritty/alacritty.git
        cd alacritty || exit 2
        git pull
        cargo build --release
        infocmp alacritty > /dev/null || sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
        sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
        sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
        sudo mkdir -p /usr/local/share/man/man1
        gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
    fi

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

if prompt "Do you want to automatically install all dependencies?"; then
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

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        sudo chsh -s "$(which zsh)" "$USER"
    fi

    # oh-my-zsh
    [ -e ~/.oh-my-zsh ] || { sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || exit 2; }
    [ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    [ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ] || git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"
    [ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    [ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode" ] || git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
fi

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
install_file .config/aliasrc.zsh
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


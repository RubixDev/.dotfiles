#!/bin/sh

[ "$(basename "$PWD")" = .dotfiles ] || {
    echo "Please run this script from your .dotfiles project root"
    exit 1
}

prompt () {
    printf '%s [Y/n] ' "$1"
    read -r choice
    case "$choice" in
        [Yy][Ee][Ss]|[Yy]|'') return 0 ;;
        *) return 1 ;;
    esac
}

promptn () {
    printf '%s [y/N] ' "$1"
    read -r choice
    case "$choice" in
        [Yy][Ee][Ss]|[Yy]) return 0 ;;
        *) return 1 ;;
    esac
}

[ "$(id -u)" -eq 0 ] && is_root=true
command -v uname > /dev/null && [ "$(uname -o)" = "Android" ] && is_android=true

# Check if ZDOTDIR is set to non-home path
# shellcheck disable=SC2016
if [ "${ZDOTDIR:-$HOME}" = "$HOME" ] &&
    ! (grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zsh/zshenv" ||
        grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zshenv") &&
    prompt "Your ZSH config folder is set to HOME. Do you want to set it to '~/.config/zsh' globally?"
then
    [ "$is_android" = true ] || sudo=sudo
    [ -e "$PREFIX/etc/zsh/zshenv" ] || {
        $sudo mkdir -p "$PREFIX/etc/zsh"
        $sudo touch "$PREFIX/etc/zsh/zshenv"
    }
    [ -f "$PREFIX/etc/zshenv" ] && {
        $sudo tee -a "$PREFIX/etc/zsh/zshenv" > /dev/null < "$PREFIX/etc/zshenv"
        $sudo rm "$PREFIX/etc/zshenv"
    }
    [ -e "$PREFIX/etc/zshenv" ] && $sudo rm "$PREFIX/etc/zshenv"
    $sudo ln -sr "$PREFIX/etc/zsh/zshenv" "$PREFIX/etc/zshenv"
    echo 'export ZDOTDIR="$HOME/.config/zsh"' | $sudo tee -a "$PREFIX/etc/zsh/zshenv" > /dev/null
    export ZDOTDIR="$HOME/.config/zsh"
elif grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zsh/zshenv" ||
        grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zshenv"
then
    export ZDOTDIR="$HOME/.config/zsh"
fi

. ./.config/env
unset CARGO_TARGET_DIR
unset GOPATH

mkdir -p ~/.local/state/zsh
mkdir -p ~/.local/state/bash
mkdir -p "${ZDOTDIR:-$HOME}"

########## Dependency Installation ##########
want_deps () {
    prompt "Do you want to automatically install all dependencies?"
    return $?
}

install_android () {
    want_deps || return

    pkg update -y
    pkg install -y ripgrep fd neovim zsh rust fzf git onefetch curl wget shellcheck \
        nodejs exa bat tmux lf || exit 2
    cargo install proximity-sort || exit 2

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        chsh -s zsh
    fi

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if ! command -v pfetch > /dev/null; then
        curl 'https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch' -o "$PREFIX/bin/pfetch"
        chmod +x "$PREFIX/bin/pfetch"
    fi
}

install_arch () {
    if [ "$is_root" != "true" ] && prompt "Install desktop configurations?"; then
        is_desktop=true
        promptn "Install Laptop specific dependencies?" && is_laptop=true
    fi
    want_deps || return

    if command -v paru > /dev/null; then
        aur=paru
    elif command -v yay > /dev/null; then
        aur=yay
    else
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit 2
        makepkg -si --noconfirm
        cd .. || exit 2
        rm -rf paru-bin
        aur=paru
    fi

    $aur -Sy --needed --noconfirm base-devel fd ripgrep neovim zsh rustup fzf git curl wget \
        shellcheck pfetch-git neovim-plug nodejs npm exa bat tmux onefetch lf || exit 2
    rustup default > /dev/null 2>&1 || { rustup default stable || exit 2; }
    $aur -S --needed --noconfirm proximity-sort || exit 2

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        sudo chsh -s "$(which zsh)" "$USER"
    fi

    if [ "$is_desktop" = true ]; then
        $aur -S --needed --noconfirm polybar sway-launcher-desktop bspwm sxhkd dunst \
            alacritty picom nitrogen numlockx slock neovim-remote ly \
            ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono xorg xcursor-breeze \
            kvantum-theme-layan-git layan-gtk-theme-git kvantum qt5ct ttf-dejavu ttf-liberation \
            noto-fonts-cjk noto-fonts-emoji noto-fonts-extra tela-icon-theme-purple-git \
            network-manager-applet xcolor maim xsct xclip yarn || exit 2
        [ "$is_laptop" = "true" ] && { $aur -S --needed --noconfirm brightnessctl pamixer || exit 2; }

        # ----- KEYBOARD LAYOUT -----
        sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/RubixDev/HandyLinuxStuff/main/us_de_layout/install.sh)"

        # ----- QT/GTK Theme -----
        if ! grep -q 'export QT_QPA_PLATFORMTHEME=qt5ct' "${ZDOTDIR:-$HOME}/.zprofile"; then
            echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "${ZDOTDIR:-$HOME}/.zprofile"
            export QT_QPA_PLATFORMTHEME=qt5ct
        fi
        # shellcheck disable=SC2016
        if ! grep -q 'export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc"' "${ZDOTDIR:-$HOME}/.zprofile"; then
            echo 'export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc"' >> "${ZDOTDIR:-$HOME}/.zprofile"
            export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc"
        fi

        # ----- Display Manager -----
        sudo systemctl disable display-manager
        sudo systemctl enable ly
    fi
}

install_debian () {
    want_deps || return

    sudo apt update
    sudo apt install -y zsh fzf git curl wget shellcheck nodejs npm || exit 2

    command -v go > /dev/null || {
        sudo apt install -y golang || exit 2
        go get gopkg.in/niemeyer/godeb.v1/cmd/godeb || exit 2
        sudo apt remove -y golang || exit 2
        sudo apt autoremove -y || exit 2
        godeb install "$(godeb list | tail -n 1)" || exit 2
    }

    command -v lf > /dev/null || {
        env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
    }

    if ! command -v rustup > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        exec "$SHELL"
    fi

    rustup default > /dev/null 2>&1 || { rustup default stable || exit 2; }
    cargo install fd-find ripgrep proximity-sort onefetch || exit 2

    if ! command -v nvim > /dev/null; then
        wget 'https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.deb' || exit 2
        sudo apt install ./nvim-linux64.deb
        rm ./nvim-linux64.deb
    fi

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if ! command -v pfetch > /dev/null; then
        sudo curl 'https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch' -o /usr/local/bin/pfetch
        sudo chmod +x /usr/local/bin/pfetch
    fi

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        sudo chsh -s "$(which zsh)" "$USER"
    fi
}

if [ "$is_android" = true ]; then
    [ "$is_root" = true ] || install_android
else
    . /etc/os-release
    case "|$ID|$ID_LIKE|" in
        *"|arch|"*) install_arch ;;
        *"|debian|"*) install_debian ;;
        *) echo "Automatic dependency installation is not supported for this distribution" ;;
    esac
fi

########### Oh My ZSH ###########
[ -e "${ZSH:-$HOME/.oh-my-zsh}" ] || {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || exit 2
    rm ~/.zshrc
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions" ] || {
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions"
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-history-substring-search" ] || {
    git clone https://github.com/zsh-users/zsh-history-substring-search \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-history-substring-search"
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-syntax-highlighting" ] || {
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-syntax-highlighting"
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-vi-mode" ] || {
    git clone https://github.com/jeffreytse/zsh-vi-mode \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-vi-mode"
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/powerlevel10k" ] || {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/powerlevel10k"
}
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/zish.zsh-theme" ] || {
    curl https://raw.githubusercontent.com/RubixDev/zish/main/zish.zsh-theme -o \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/zish.zsh-theme"
}

########### dotfiles Installation ###########
install_file () {
    src="$1"
    if [ -n "$2" ]; then
        dest="$2"
    else
        dest="$HOME/$1"
    fi
    mkdir -p "$(dirname "$dest")"
    [ ! -L "$dest" ] || rm "$dest"
    [ ! -e "$dest" ] || mv "$dest" "$dest".old
    echo "Linking '$PWD/$src' to '$dest'"
    ln -s "$PWD/$src" "$dest"
}

# Uninstall SpaceVim if present
[ -e ~/.SpaceVim ] && curl -sLf https://spacevim.org/install.sh | bash -s -- --uninstall

# Create symlinks
install_file .zshrc "${ZDOTDIR:-$HOME}/.zshrc"
install_file .p10k.zsh "${ZDOTDIR:-$HOME}/.p10k.zsh"
install_file .bashrc
install_file .config/env
install_file .config/aliasrc
install_file .config/tmux/tmux.conf
install_file .config/nvim/init.vim
install_file .config/paru/paru.conf
install_file .config/npm/npmrc
if [ "$is_desktop" = true ]; then
    install_file .config/alacritty/alacritty.yml
    install_file .config/i3/config
    install_file .config/bspwm/bspwmrc
    install_file .config/sxhkd/sxhkdrc
    install_file .config/dunst/dunstrc
    install_file .config/picom.conf
    install_file .config/polybar/config.ini
    install_file .gtkrc-2.0 "${GTK2_RC_FILES:-$HOME/.gtkrc-2.0}"
    install_file .config/gtk-3.0/settings.ini
    install_file .config/qt5ct/qt5ct.conf
    install_file .icons/default/index.theme
    install_file .config/Kvantum/kvantum.kvconfig
fi

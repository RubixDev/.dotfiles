#!/bin/sh

[ "$(basename "$PWD")" = .dotfiles ] || {
    echo "Please run this script from your .dotfiles project root"
    exit 1
}

while [ $# -ne 0 ]; do
    if [ "$1" = "--only-link" ]; then
        only_link="true"
    fi
    shift
done

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
(
    grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zsh/zshenv" > /dev/null 2>&1 ||
    grep -q 'export ZDOTDIR="$HOME/.config/zsh"' "$PREFIX/etc/zshenv" > /dev/null 2>&1
) && set_in_file=true
if [ "${ZDOTDIR:-$HOME}" = "$HOME" ] &&
    [ "$set_in_file" != true ] &&
    [ "$only_link" != true ] &&
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
    # shellcheck disable=SC2016
    echo 'export ZDOTDIR="$HOME/.config/zsh"' | $sudo tee -a "$PREFIX/etc/zsh/zshenv" > /dev/null
    export ZDOTDIR="$HOME/.config/zsh"
elif [ "$set_in_file" = true ] && [ "$only_link" != true ]; then
    export ZDOTDIR="$HOME/.config/zsh"
fi

. ./.config/env

mkdir -p ~/.local/state/zsh
mkdir -p ~/.local/state/bash
mkdir -p "${ZDOTDIR:-$HOME}"

########## Dependency Installation ##########
want_deps () {
    [ "$only_link" != true ] || return 0
    prompt "Do you want to automatically install all dependencies?"
    return $?
}

install_android () {
    want_deps || return

    pkg update -y
    pkg install -y ripgrep fd neovim zsh rust fzf git onefetch curl wget shellcheck \
        nodejs exa bat tmux lf python || exit 2
    cargo install pixterm dprint || exit 2

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        chsh -s zsh
    fi

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    if ! command -v pfetch > /dev/null; then
        platform=android-aarch64
        dir=pfetch-$platform

        curl -LO https://github.com/Gobidev/pfetch-rs/releases/latest/download/$dir.tar.gz
        tar -xvf $dir.tar.gz

        install -Dm755 pfetch "$PREFIX/bin/pfetch"

        rm -r pfetch $dir.tar.gz
        unset -v platform dir
    fi
}

install_arch () {
    [ "$only_link" = true ] && return
    unset CARGO_TARGET_DIR
    unset GOPATH
    [ "$is_root" != true ] && prompt "Install desktop configurations?" && is_desktop=true
    want_deps || return
    [ "$is_desktop" = true ] && promptn "Install Laptop specific dependencies?" && is_laptop=true

    if command -v paru > /dev/null; then
        aur=paru
    elif command -v yay > /dev/null; then
        aur=yay
    elif [ "$is_root" != true ]; then
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit 2
        makepkg -si --noconfirm || exit 2
        cd .. || exit 2
        rm -rf paru-bin
        aur=paru
    fi

    $aur -Sy --needed --noconfirm base-devel fd ripgrep neovim zsh rustup fzf git curl wget \
        shellcheck pfetch-rs-bin nodejs npm exa bat tmux onefetch joshuto-bin lf go dprint \
        || [ "$is_root" = true ] || exit 2
    rustup default > /dev/null 2>&1 || { rustup default stable || exit 2; }
    $aur -S --needed --noconfirm pixterm-rust autojump-rs \
        || [ "$is_root" = true ] || exit 2

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        sudo chsh -s "$(which zsh)" "$USER"
    fi

    if [ "$is_desktop" = true ]; then
        $aur -S --needed --noconfirm polybar sway-launcher-desktop bspwm sxhkd dunst \
            wezterm picom nitrogen numlockx slock neovim-remote ly \
            ttf-jetbrains-mono-nerd ttf-jetbrains-mono xorg xcursor-breeze \
            kvantum-theme-layan-git layan-gtk-theme-git kvantum qt5ct ttf-dejavu ttf-liberation \
            noto-fonts-cjk noto-fonts-emoji noto-fonts-extra tela-icon-theme-purple-git \
            network-manager-applet xcolor maim xsct xclip yarn rtkit lxqt-policykit || exit 2
        [ "$is_laptop" = true ] && { $aur -S --needed --noconfirm brightnessctl pamixer || exit 2; }

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
    sudo apt install -y zsh fzf git curl wget shellcheck nodejs npm autojump python3-venv || exit 2

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
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    fi

    rustup default > /dev/null 2>&1 || { rustup default stable || exit 2; }
    cargo install fd-find ripgrep onefetch pixterm autojump tree-sitter-cli bat dprint exa pfetch || exit 2

    if ! command -v nvim > /dev/null; then
        wget 'https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.deb' || exit 2
        sudo apt install ./nvim-linux64.deb
        rm ./nvim-linux64.deb
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
install_zsh_custom () {
    [ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/$1/$3" ] || {
        git clone --depth=1 "https://github.com/$2/$3" \
            "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/$1/$3"
    }
}
install_zsh_custom plugins zsh-users zsh-autosuggestions
install_zsh_custom plugins zsh-users zsh-syntax-highlighting
install_zsh_custom plugins jeffreytse zsh-vi-mode
install_zsh_custom themes romkatv powerlevel10k
[ -e "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/zish.zsh-theme" ] || {
    curl https://raw.githubusercontent.com/RubixDev/zish/main/zish.zsh-theme -o \
        "${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/themes/zish.zsh-theme"
}

########### dotfiles Installation ###########
link () {
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
link .zshrc "${ZDOTDIR:-$HOME}/.zshrc"
link .p10k.zsh "${ZDOTDIR:-$HOME}/.p10k.zsh"
link .bashrc
link .config/env
link .config/aliasrc
link .config/tmux/tmux.conf
link .config/nvim/init.vim
link .config/nvim/lua
link .config/nvim/queries
link .config/paru/paru.conf
link .config/git/config
link .config/python/pythonrc
link .config/bpython/config
link .config/pixfetch/config.toml
link .config/dprint
if [ "$is_desktop" = true ]; then
    link .config/alacritty/alacritty.yml
    link .config/bspwm/bspwmrc
    link .config/sxhkd/sxhkdrc
    link .config/dunst/dunstrc
    link .config/picom.conf
    link .config/polybar/config.ini
    link .gtkrc-2.0 "${GTK2_RC_FILES:-$HOME/.gtkrc-2.0}"
    link .config/gtk-3.0/settings.ini
    link .config/qt5ct/qt5ct.conf
    link .icons/default/index.theme
    link .config/Kvantum/kvantum.kvconfig
    link .config/BetterDiscord/themes/SimplyTransparent.theme.css
    link .config/joshuto
    link .config/wezterm

    # XDG-MIME default apps
    link .config/mimeapps.list
    link .local/share/applications/joshuto.desktop
    link .local/share/applications/nsxiv.desktop
    link .local/share/applications/nvim.desktop
    link .local/share/applications/zathura.desktop
fi

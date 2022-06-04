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

# Check if ZDOTDIR is set to non-home path
if [ "${ZDOTDIR:-$HOME}" = "$HOME" ] && prompt "Your ZSH config folder is set to HOME. Do you want to set it to '~/.config/zsh' with sudo?"; then
    [ -e /etc/zsh/zshenv ] || {
        sudo mkdir -p /etc/zsh
        sudo touch /etc/zsh/zshenv
    }
    # shellcheck disable=SC2016
    echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zsh/zshenv > /dev/null
    source /etc/zsh/zshenv
fi

source ./.config/env

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
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit 2
        makepkg -si --noconfirm
        cd .. || exit 2
        rm -rf paru-bin
        aur=paru
    fi

    $aur -Sy --needed --noconfirm base-devel fd ripgrep neovim zsh rustup fzf git curl wget \
        shellcheck pfetch neovim-plug nodejs npm yarn exa bat tmux xclip || exit 2
    rustup default > /dev/null || { rustup default stable || exit 2; }
    $aur -S --needed --noconfirm proximity-sort || exit 2

    if [ "$is_desktop" = true ]; then
        $aur -S --needed --noconfirm polybar sway-launcher-desktop bspwm sxhkd dunst \
            alacritty picom nitrogen numlockx slock neovim-remote \
            ttf-meslo-nerd-font-powerlevel10k ttf-jetbrains-mono xorg xcursor-breeze \
            kvantum-theme-layan-git layan-gtk-theme-git kvantum qt5ct ttf-dejavu ttf-liberation \
            noto-fonts-cjk noto-fonts-emoji noto-fonts-extra tela-icon-theme gtkrc-reload || exit 2

        # ----- KEYBOARD LAYOUT -----
        # Remove layout from US file if present
        sudo perl -0777 -i -p -e 's/xkb_symbols "us_de"[\s\S]*?\n};\n?//g' /usr/share/X11/xkb/symbols/us || exit 1
        # Add layout to US layout file
        echo | sudo tee -a /usr/share/X11/xkb/symbols/us > /dev/null
        # shellcheck disable=SC2024
        sudo tee -a /usr/share/X11/xkb/symbols/us < ./us_de.xkb > /dev/null || exit 1
        # Remove layout from evdev.xml if present
        sudo perl -0777 -i -p -e 's/<variant>[\s\S]*?<description>QWERTY with german Umlaut keys<\/description>[\s\S]*?<\/variant>\n?\s*//g' /usr/share/X11/xkb/rules/evdev.xml || exit 1
        # Make layout available in system settings
        sudo perl -0777 -i -p -e 's/(<layout>[\s\S]*?<description>English \(US\)<\/description>[\s\S]*?<variantList>\n?)(\s*)/\1\2<variant>\n\2  <configItem>\n\2    <name>us_de<\/name>\n\2    <description>QWERTY with german Umlaut keys<\/description>\n\2    <languageList>\n\2      <iso639Id>eng<\/iso639Id>\n\2      <iso639Id>ger<\/iso639Id>\n\2    <\/languageList>\n\2  <\/configItem>\n\2<\/variant>\n\2/g' /usr/share/X11/xkb/rules/evdev.xml || exit 1

        # ----- QT/GTK Theme -----
        [ "$QT_QPA_PLATFORMTHEME" = "qt5ct" ] || {
            echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "${ZDOTDIR:-$HOME}/.zprofile"
            export QT_QPA_PLATFORMTHEME=qt5ct
        }
        kvantummanager --set Layan
        gtkrc-reload
    fi
}

install_debian () {
    sudo apt update
    sudo apt install -y zsh fzf git curl wget shellcheck nodejs npm || exit 2
    [ "$is_desktop" = true ] && sudo apt install -y bspwm sxhkd polybar dunst picom nitrogen \
        numlockx suckless-tools cmake pkg-config libfreetype6-dev libfontconfig1-dev \
        libxcb-xfixes0-dev libxkbcommon-dev python3 fonts-jetbrains-mono

    sudo npm install -g yarn || exit 2

    if ! command -v rustup > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        exec "$SHELL"
    fi

    rustup default > /dev/null || { rustup default stable || exit 2; }
    cargo install fd-find ripgrep proximity-sort || exit 2

    if [ "$is_desktop" = true ]; then
        if ! command -v alacritty > /dev/null; then
            git clone https://github.com/alacritty/alacritty.git
            cd alacritty || exit 2
            git pull
            cargo build --release
            infocmp alacritty > /dev/null || sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
            sudo cp "${CARGO_TARGET_DIR:-target}"/release/alacritty /usr/local/bin
            sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
            sudo desktop-file-install extra/linux/Alacritty.desktop
            sudo update-desktop-database
            sudo mkdir -p /usr/local/share/man/man1
            gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
            gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
            cd .. || exit 2
            rm -rf alacritty
        fi

        fontpath="/usr/share/fonts/truetype/meslo"
        sudo mkdir -p "$fontpath"
        [ -e "$fontpath"/MesloLGS_NF_Regular.ttf ] || sudo curl 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf' -o "$fontpath"/MesloLGS_NF_Regular.ttf
        [ -e "$fontpath"/MesloLGS_NF_Bold.ttf ] || sudo curl 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf' -o "$fontpath"/MesloLGS_NF_Bold.ttf
        [ -e "$fontpath"/MesloLGS_NF_Italic.ttf ] || sudo curl 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf' -o "$fontpath"/MesloLGS_NF_Italic.ttf
        [ -e "$fontpath"/MesloLGS_NF_Bold_Italic.ttf ] || sudo curl 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf' -o "$fontpath"/MesloLGS_NF_Bold_Italic.ttf
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
fi

########### Oh My ZSH ###########
[ -e "${ZSH:-$HOME/.oh-my-zsh}" ] || {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || exit 2
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

mkdir -p ~/.local/state/zsh
mkdir -p ~/.local/state/bash

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
    install_file .config/terminator/config
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
fi


alias tmux='tmux -2'
alias cp='cpv -iv'
alias mv='mv -iv'
alias rm='rm -v'
alias ip='ip -c'
alias l='exa -lahg --icons --octal-permissions'
alias ll='exa -lhg --icons --octal-permissions'

updaterc () {
    current_dir="$PWD"
    cd ~/.dotfiles || {
        echo 'The .dotfiles folder should be at ~/.dotfiles to auto update'
        return 2
    }
    git pull
    ./install.sh
    cd "$current_dir" || return 2
    # Reload shell
    exec "$SHELL"
}
editrc () {
    [[ -d "$HOME/.dotfiles" ]] || {
        echo 'No .dotfiles folder at ~/.dotfiles'
        return 2
    }
    code ~/.dotfiles
}

command -v xclip >/dev/null && { alias setclip='xclip -selection c'; alias getclip='xclip -selection c -o'; }
command -v wl-copy >/dev/null && { alias setclip='wl-copy'; alias getclip='wl-paste'; }

alias root='sudo su -'
alias con='ssh contabo'
alias poof='poweroff'
alias pubip='curl ipinfo.io/ip'
alias apdate='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'

makeinvert () {
    pwd="$PWD"

    cd ~/Downloads || return 1
    if [[ -d kwin-effect-smart-invert ]]; then
        cd kwin-effect-smart-invert || return 2
        git pull || {
            cd "$pwd"
            return 3
        }
    else
        git clone https://github.com/natask/kwin-effect-smart-invert.git || {
            cd "$pwd"
            return 2
        }
        cd kwin-effect-smart-invert || return 3
    fi

    sed -i 's/m_allWindows(true)/m_allWindows(false)/' invert.cpp
    mkdir -p build
    cd build || return 4
    cmake .. && make && sudo make install && (kwin_x11 --replace &)

    cd "$pwd"
}
remakeinvert () {
    pwd="$PWD"

    cd ~/Downloads || return 1
    [[ -d kwin-effect-smart-invert ]] || {
        echo "Cloned repo not found at ~/Downloads/kwin-effect-smart-invert"
        cd "$pwd"
        return 2
    }
    cd kwin-effect-smart-invert || return 3
    sed -i 's/m_allWindows(true)/m_allWindows(false)/' invert.cpp
    [[ -d build ]] || {
        echo "No previous build folder present"
        cd "$pwd"
        return 4
    }
    cd build
    sudo make install && (kwin_x11 --replace &)

    cd "$pwd"
}

rewg () {
    systemctl is-active wg-quick@wg0 > /dev/null && {
        sudo systemctl restart wg-quick@wg0
        return 0
    }
    systemctl is-active wg-quick@wg1 > /dev/null && {
        sudo systemctl restart wg-quick@wg1
        return 0
    }
    echo "No known wg service is running"
    return 3
}
alias wg0='sudo systemctl stop wg-quick@wg1 && sudo systemctl start wg-quick@wg0'
alias wg1='sudo systemctl stop wg-quick@wg0 && sudo systemctl start wg-quick@wg1'

alias lelcat='bash -c "$(curl -fsSL https://raw.githubusercontent.com/RubixDev/HandyLinuxStuff/main/meow.sh)"'
cheat () { curl -s "cheat.sh/$1" | less; }
timeout () { sleep "$1"; shift; bash -c "$*"; }
colors () {
    for i in {0..255}; do
        print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
    done
}

postclip () { curl -sSL https://clip.rubixdev.de/index.php -F data="$1" -o /dev/null; }
alias fetchclip='curl -sSL https://clip.rubixdev.de/clipboard.txt'

untis () {
    user="$1"
    [[ -n "$user" ]] || {
        echo "No user specified"
        return 1
    }
    date="$2"
    [[ -n "$date" ]] || {
        echo "No date specified"
        return 1
    }

    [[ -f ~/.untisusers.json ]] || {
        echo "No '.untisusers.json' in home directory"
        return 1
    }

    username="$(jq -r ".$user.username" ~/.untisusers.json)"
    password="$(jq -r ".$user.password" ~/.untisusers.json)"
    [[ "$username" != "null" ]] && [[ "$password" != "null" ]] || {
        echo "User not found in ~/.untisusers.json"
        return 1
    }

    if [[ -n "$3" ]]; then
        filtered="true"
    else
        filtered="false"
    fi

    curl -X POST -H 'Content-Type: application/json' -d "{\"username\":\"$username\",\"password\":\"$password\",\"filtered\":$filtered}" "https://untis.rubixdev.de/timetable/$date" | jq
}
findfont () {
    [[ -n "$1" ]] || {
        echo "Please specify a symbol to search for"
        return 1
    }
    python -c "import os

fonts = []

def add_fonts(directory):
    if not os.path.isdir(directory): return
    for root,dirs,files in os.walk(directory):
        for file in files:
            if file.endswith('.ttf'): fonts.append(os.path.join(root,file))

add_fonts('/usr/share/fonts/')
add_fonts('$HOME/.local/share/fonts/')
add_fonts('$HOME/.fonts/')


from fontTools.ttLib import TTFont

def char_in_font(unicode_char, font):
    for cmap in font['cmap'].tables:
        if cmap.isUnicode():
            if ord(unicode_char) in cmap.cmap:
                return True
    return False

def test(char):
    for fontpath in fonts:
        font = TTFont(fontpath)   # specify the path to the font in question
        if char_in_font(char, font):
            print(char + ' in ' + fontpath)

test('$1')"
}

alias sr='screen -r'
alias sls='screen -ls'

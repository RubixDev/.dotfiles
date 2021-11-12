alias tmux='tmux -2'
alias cp='cpv -iv'
alias mv='mv -iv'
alias rm='rm -v'
alias ip='ip -c'
alias l='exa -lahg --icons --octal-permissions'

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

command -v xclip >/dev/null && { alias setclip='xclip -selection c'; alias getclip='xclip -selection c -o'; }
command -v wl-copy >/dev/null && { alias setclip='wl-copy'; alias getclip='wl-paste'; }

alias root='sudo su -'
alias con='ssh contabo'
alias poof='poweroff'
alias pubip='curl ipinfo.io/ip'

alias wg0='sudo systemctl stop wg-quick@wg1 && sudo systemctl start wg-quick@wg0'
alias wg1='sudo systemctl stop wg-quick@wg0 && sudo systemctl start wg-quick@wg1'

alias lelcat='bash -c "$(wget -O- https://raw.githubusercontent.com/RubixDev/HandyLinuxStuff/main/meow.sh)"'
cheat () { curl -s "cheat.sh/$1" | less; }
timeout () { sleep "$1"; shift; bash -c "$*"; }
colors () {
    for i in {0..255}; do
        print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
    done
}

alias sr='screen -r'
alias sls='screen -ls'

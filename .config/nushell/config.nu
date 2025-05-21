### Theme
use nu-themes/one-dark.nu
one-dark set color_config
$env.config.color_config.shape_external_resolved = { fg: '#56b6c2' attr: 'b' }

### Host detection
let host = {
  is-desktop: (sys host | get hostname | $in == 'slas-arch')
  is-laptop: (sys host | get hostname | $in == 'archtop')
  is-worktop: (sys host | get hostname | $in == 'J4ST044')
}

### Config
$env.config.history = {
  file_format: sqlite
  max_size: 5_000_000
  sync_on_enter: true
  isolation: false
}

$env.config.show_banner = false
$env.config.rm.always_trash = false
# $env.config.recursion_limit = 50
$env.config.edit_mode = 'vi'
$env.config.buffer_editor = 'hx'
$env.config.cursor_shape = {
  emacs: inherit
  vi_normal: block
  vi_insert: line
}
$env.config.completions.algorithm = 'prefix'
$env.config.footer_mode = 'auto'
$env.config.table.mode = 'compact'
$env.config.filesize = {
  unit: metric
  show_unit: true
  precision: 2
}
$env.config.highlight_resolved_externals = not $host.is-worktop

$env.config.keybindings ++= [
]

### Aliases
overlay use git_aliases/git-aliases.nu

alias jobs = job list
alias fg = job unfreeze

alias tmux = tmux -2
alias cp = cp -iv
alias mv = mv -iv
alias ip = ip -c
alias ipa = ip -br -c a
alias li = pixterm -fa

def --wrapped --env mkcd [...rest] {
  mkdir ...$rest
  cd ($rest | last)
}

let ls_cmd = if (which eza | is-not-empty) {
  [eza -lahg --icons --octal-permissions --git]
} else if (which exa | is-not-empty) {
  [exa -lahg --icons --octal-permissions --git]
} else {
  [ls -lAh --color=auto]
}
alias l = ^($ls_cmd | first) ...($ls_cmd | skip 1)

alias dprinit = cp ~/.config/dprint/dprint.json dprint.json
alias dprintg = dprint --config ($env.XDG_CONFIG_HOME | path join dprint/dprint.json)

def editrc [] {
  if ('~/.dotfiles' | path type) != dir {
    error make { msg: 'No .dotfiles folder at ~/.dotfiles' }
  }
  ^$env.config.buffer_editor ~/.dotfiles
}

def gpgedit [file: string] {
  let tmp_path = $"/tmp/__gpgedit-($file)-(random chars --length 10)"
  if ($file | path exists) {
    gpg -o $tmp_path --decrypt $file
  }
  ^$env.config.buffer_editor $tmp_path
  gpg -o $file --default-recipient-self --encrypt $tmp_path
  rm $tmp_path
}

alias con = ssh contabo
alias poof = poweroff
alias pubip = curl ipinfo.io/ip
alias occ = sudo docker exec -u www-data -it nextcloud php occ
alias sctl = sudo systemctl
# alias sr = screen -r
# alias sls = screen -ls

# this sadly breaks completions, see https://github.com/nushell/nushell/issues/14504
def --wrapped paru [...args] {
  hide-env CARGO_TARGET_DIR GOPATH
  ^paru ...$args
}

def scrsingle [] {
  swaymsg output HEADLESS-1 resolution 1920x1200
  swaymsg output HEADLESS-2 disable
  wayvncctl -S /tmp/wayvnc-sock output-set HEADLESS-1
}

def scrdouble [] {
    swaymsg output HEADLESS-1 resolution 2560x1440
    swaymsg output HEADLESS-2 enable
    wayvncctl -S /tmp/wayvnc-sock output-set HEADLESS-2
}

def scrreload [] {
    wayvncctl output-set HEADLESS-2
    wayvncctl output-set HEADLESS-1
}

def rewg [] {
  if (systemctl is-active wg-quick@wg0 | complete).exit_code == 0 {
    sudo systemctl restart wg-quick@wg0
  } else if (systemctl is-active wg-quick@wg0 | complete).exit_code == 0 {
    sudo systemctl restart wg-quick@wg1
  } else {
    error make { msg: 'no known wireguard service is running' }
  }
}
alias wg0 = do { sudo systemctl stop wg-quick@wg1; sudo systemctl start wg-quick@wg0 }
alias wg1 = do { sudo systemctl stop wg-quick@wg0; sudo systemctl start wg-quick@wg1 }
alias stopwg = do { sudo systemctl stop wg-quick@wg0; sudo systemctl stop wg-quick@wg1 }

alias 'clip get' = if (which wl-paste | is-not-empty) { wl-paste } else { xclip -selection c -o }
alias 'clip set' = if (which wl-copy | is-not-empty) { wl-copy } else { xclip -selection c }
def 'clip fetch' [] { http get https://clip.rubixdev.de/clipboard }
def 'clip post' [] { http post https://clip.rubixdev.de/clipboard $in }
def 'clip load' [] { clip fetch | clip set }
def 'clip share' [] { clip get | clip post }

def 'upd log trace' [msg: string] { print $"(ansi cb)> ($msg)(ansi reset)" }
def 'upd log info' [msg: string] { print $"(ansi gb)>>> ($msg)(ansi reset)" }
def 'upd log warn' [msg: string] { print $"(ansi yb)>>> Warning: ($msg)(ansi reset)" }
def 'upd log error' [msg: string = 'update failed'] { print $"(ansi rb)>>> Error: ($msg)(ansi reset)" }

def 'upd rc' [--no-exec] {
  upd log info 'updating dotfiles'
  try { cd ~/.dotfiles } catch {
    upd log error 'The .dotfiles folder should be at ~/.dotfiles to auto update'
    return
  }
  git pull
  ./install.sh --only-link

  # Reload shell
  if not $no_exec {
    upd log trace 'replacing shell process'
    exec nu
  }
}

def 'upd pkg' [] {
  upd log info 'updating system packages'
  if (uname | get operating-system) == 'Android' {
    pkg upgrade
    apt autoremove
  } else if (which apt | is-not-empty) {
    try { sudo apt update } catch { upd log error 'failed to update APT packages'; return }
    try { sudo apt upgrade } catch { upd log error 'failed to upgrade APT packages'; return }
    sudo apt autoremove
    sudo apt autoclean
  } else {
    try { paru -Syu } catch { upd log error; return }
  }
}

def 'upd rust' [] {
  if (which rustup | is-empty) { return }
  upd log info 'updating Rust toolchains'
  try { rustup update } catch { upd log error; return }
}

def 'upd cargo' [] {
  if (which cargo | is-empty) { return }
  upd log info 'updating cargo packages'
  let crates = (cargo install --list | lines | every 2 | parse -r '\A(?P<name>.*?) (?P<version>.*?)(?: \((?P<git>.*?)\))?:\z')
  cargo install ...($crates | where git == '' | get name)
  for crate in ($crates | where git != '') {
    cargo install --git ($crate.git | url parse | reject fragment | url join)
  }
}

def 'upd nu' [] {
  upd log info 'updating nushell libs and plugins'
  for dir in (glob ($nu.default-config-dir | path join lib/* | into glob)) {
    cd $dir
    upd log trace $dir
    try { git pull } catch { upd log error $'updating ($dir) failed'; return }
  }
}

# TODO: upd nvim ?

def 'upd flatpak' [] {
  if (which flatpak | is-empty) { return }
  upd log info 'updating Flatpaks'
  try { flatpak update } catch { upd log error; return }
}

def 'upd gpg' [] {
  if (which gpg | is-empty) { return }
  upd log info 'refreshing GPG keys'
  try { gpg --refresh-keys } catch { upd log error; return }
}

# TODO: npm ?

def upd [] {
  try { upd rc --no-exec } catch { upd log warn 'skipping failed dotfiles update' }
  # TODO: reload shell
  try { upd pkg } catch { upd log warn 'skipping failed system package updates' }
  try { upd rust} catch { upd log warn 'skipping failed Rust updates' }
  try { upd cargo } catch { upd log warn 'skipping failed cargo updates' }
  try { upd nu } catch { upd log warn 'skipping failed nushell updates' }
  try { upd flatpak } catch { upd log warn 'skipping failed Flatpak updates' }
  try { upd gpg } catch { upd log warn 'skipping failed GPG keyring update' }
}

### Env
if (which vivid | is-not-empty) {
  $env.LS_COLORS = (vivid generate one-dark)
}

$env.EDITOR = $env.config.buffer_editor

### Plugins
plugin use clipboard
plugin use file

### Prompt
source /tmp/omp.nu
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''

### Completions
source /tmp/carapace.nu

### Greeting
print ''
pfetch

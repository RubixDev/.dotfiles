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

### Env
if (which vivid | is-not-empty) {
  $env.LS_COLORS = (vivid generate one-dark)
}

### Plugins
plugin use clipboard

### Prompt
source /tmp/omp.nu
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

### Completions
source /tmp/carapace.nu

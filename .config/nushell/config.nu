### Theme
use nu-themes/onedark.nu
onedark set color_config

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
$env.config.completions.algorithm = 'fuzzy'
# TODO: carapace
$env.config.footer_mode = 'auto'
$env.config.table.mode = 'compact'
$env.config.filesize = {
  unit: metric
  show_unit: true
  precision: 2
}
$env.config.highlight_resolved_externals = false

$env.config.keybindings ++= [
]

$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""

### Aliases
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

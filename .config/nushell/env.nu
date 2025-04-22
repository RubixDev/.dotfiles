### Prompt
oh-my-posh init nu --print | save /tmp/omp.nu --force

### Completions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
carapace _carapace nushell | save --force /tmp/carapace.nu

### Libs
const libs_dir = ($nu.default-config-dir | path join lib)
$env.NU_LIB_DIRS ++= [
  $libs_dir
  ($libs_dir | path join nu_scripts/themes)
]

mkdir $libs_dir

def clone-lib [
  name: string
  url: string
] {
  let p = $libs_dir | path join $name
  if not ($p | path exists) {
    git clone $url $p
  }
}

clone-lib nu_scripts https://github.com/nushell/nu_scripts
clone-lib git_aliases https://github.com/KamilKleina/git-aliases.nu

### Plugins
$env.NU_PLUGIN_DIRS ++= [($env.CARGO_HOME? | default ~/.cargo | path join bin)]
def "plugin fetch" [name: string, url: string] {
  if ($nu.plugin-path | path exists) and ($name in (open $nu.plugin-path | get plugins.name)) {
    return
  }
  cargo install --git $url
  plugin add nu_plugin_($name)
}

plugin fetch clipboard https://github.com/FMotalleb/nu_plugin_clipboard


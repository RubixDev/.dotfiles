local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
    return
end

treesitter.setup {
    ensure_installed = {
        'bash',
        'bibtex',
        'c',
        'cpp',
        'css',
        'dockerfile',
        'gdscript',
        -- 'gitattributes', -- currently experimental
        'gitignore',
        'go',
        'godot_resource',
        'gomod',
        'html',
        'java',
        'javascript',
        'json',
        'json5',
        'jsonc',
        'kotlin',
        'latex',
        'lua',
        'make',
        'markdown', -- currently experimental
        'markdown_inline', -- currently experimental
        'python',
        'rust',
        'scss',
        'svelte',
        'sxhkdrc',
        'toml',
        'typescript',
        'vim',
        'yaml',
    },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        disable = {
            'bash',
            'sxhkdrc',
        },
        additional_vim_regex_highlighting = false,
    }
}

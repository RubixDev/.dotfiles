return {
    extra_filetypes = { 'svelte' },
    extra_args = function(params)
        local has_local_config = require('null-ls.utils').make_conditional_utils().root_has_file {
            'package.json',
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.yml',
            '.prettierrc.yaml',
            '.prettierrc.json5',
            '.prettierrc.js',
            '.prettierrc.cjs',
            '.prettierrc.config.js',
            '.prettierrc.config.cjs',
            '.prettierrc.toml',
        }
        if has_local_config then
            return {}
        end

        -- Default config
        return {
            '--tab-width',
            params.options.tabSize,
            '--no-semi',
            '--single-quote',
            '--trailing-comma=all',
            '--arrow-parens=avoid',
            '--prose-wrap=always',
        }
    end,
}

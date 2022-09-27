return {
    filetypes = {}, -- All file types
    extra_args = function()
        local has_local_config = require('null-ls.utils').make_conditional_utils().root_has_file {
            'dprint.json',
            '.dprint.json',
        }
        if has_local_config then return {} end

        -- Default config
        local config_path = (vim.env.XDG_CONFIG_HOME or vim.env.HOME .. '/.config') .. '/dprint/dprint.json'
        return { '--config', config_path }
    end,
}

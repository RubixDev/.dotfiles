local M = {}

function M.try_setup(module_name, opts_or_callback)
    local ok, module = pcall(require, module_name)
    if ok then
        local opts_type = type(opts_or_callback)
        if opts_type == 'function' then
            opts_or_callback(module)
        else
            module.setup(opts_or_callback)
        end
    else
        vim.schedule(
            function() vim.notify(('Failed to require plugin %s'):format(module_name), vim.log.levels.WARN) end
        )
    end
end

return M

local autopairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
local utils = require('nvim-autopairs.utils')

autopairs.setup {
    check_ts = true,
}

-- From `{|}` to `{ | }` when pressing <space>
-- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules#add-spaces-between-parentheses
autopairs.add_rules {
    Rule(' ', ' '):with_pair(function(opts)
        local pair = opts.line:sub(opts.col - 1, opts.col)
        return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
    Rule('( ', ' )')
        :with_pair(cond.none())
        :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
    Rule('{ ', ' }')
        :with_pair(cond.none())
        :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
    Rule('[ ', ' ]')
        :with_pair(cond.none())
        :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']'),
}

-- Allow jumping to closing pair in next line
-- https://github.com/windwp/nvim-autopairs/issues/167#issuecomment-1089688919
local function multiline_close_jump(open, close)
    return Rule(close, '')
        :with_pair(function()
            local row, col = utils.get_cursor()
            local line = utils.text_get_current_line(0)

            -- Require cursor at end of line
            if #line ~= col then
                return false
            end

            -- Prefer closing unclosed pairs
            local unclosed_count = 0
            for c in line:gmatch('[\\' .. open .. '\\' .. close .. ']') do
                if c == open then
                    unclosed_count = unclosed_count + 1
                end
                if unclosed_count > 0 and c == close then
                    unclosed_count = unclosed_count - 1
                end
            end
            if unclosed_count > 0 then
                return false
            end

            -- Find row with closing pair
            local nextrow = row + 1
            ---- Allow blank lines
            while nextrow < vim.api.nvim_buf_line_count(0) and vim.regex('^\\s*$'):match_line(0, nextrow) do
                nextrow = nextrow + 1
            end
            if nextrow < vim.api.nvim_buf_line_count(0) and vim.regex('^\\s*' .. close):match_line(0, nextrow) then
                return true
            end
            return false
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        :with_del(cond.none())
        :set_end_pair_length(0)
        :replace_endpair(function()
            return '<esc>xEa'
        end)
end

autopairs.add_rules {
    multiline_close_jump('(', ')'),
    multiline_close_jump('[', ']'),
    multiline_close_jump('{', '}'),
}

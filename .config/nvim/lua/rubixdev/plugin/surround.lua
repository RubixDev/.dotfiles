local surround = require('surround')

surround.setup {
    context_offset = 150, -- Lines of code above and below to search for nested pairs
    mappings_style = 'sandwich',
    quotes = { "'", '"', '`' },
}

-- I thought this would make scrolling more pleasing on the eyes but it doesn't.
return {
    {
        'echasnovski/mini.nvim',
        version = false,
        enabled = false,
        config = function()
            require('mini.animate').setup()
        end
    },
    {
        "karb94/neoscroll.nvim",
        enabled = false,
        opts = {},
    }
}

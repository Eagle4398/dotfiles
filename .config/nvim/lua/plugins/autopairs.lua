return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
    dependencies = {"hrsh7th/nvim-cmp"},
    init = function()
        vim.g.AutoPairsShortcutJump = '<C-l>'
        -- add autopairs after you autocomplete a function with cmp
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )
    end,
    -- opts = {disable_filetype = {"typst"}}
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
}

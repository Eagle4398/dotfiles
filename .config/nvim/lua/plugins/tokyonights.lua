return {
    {
        "folke/tokyonight.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = -1, -- make sure to load this before all the other start plugins
        enabled = false,
        config = function()
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            vim.cmd([[colorscheme rose-pine]])
            vim.api.nvim_set_hl(0, "Normal", {bg = None})
            vim.api.nvim_set_hl(0, "NormalFloat", {bg = None})
        end
    }
}

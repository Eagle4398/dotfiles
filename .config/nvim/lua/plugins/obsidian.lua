-- This is not configured at all (especially with templates) but it makes 
-- Obsidian files look nice so there's that.
return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
        -- refer to `:h file-pattern` for more examples
        "BufReadPre ~/projects/Obsidian/*.md",
        "BufNewFile ~/projects/Obsidian/*.md",
        "BufReadPre ~/projects/Obsidian/**/*.md",
        "BufNewFile ~/projects/Obsidian/**/*.md",
    },
    dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
        'nvim-telescope/telescope.nvim',

        -- see below for full list of optional dependencies 👇
    },
    opts = {
        workspaces = {
            {
                name = "ObsidianVault1",
                path = "~/projects/Obsidian",
            }
        },

        -- see below for full list of options 👇
    },
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
                local filepath = vim.fn.expand("%:p")
                if filepath:match("^~/projects/Obsidian/") then
                    vim.opt.conceallevel = 2
                end
            end,
        })
    end,
}

-- This is a massive, massive file.
-- The main problem is to get the dependencies working.
-- For tabout, I needed to ensure it's only ran after treesitter.
-- For the latex snippets I needed to ensure it's ran after luasnip.
-- And for cmp I need to depend on LuaSnip to get the snippet integration work properly

return { {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp", -- be careful that this doesn't fail.
        -- if you've installed LuaSnip and then added the build attribute,
        -- it won't actually automatically rebuild.
        enabled = true,

        config = function()
            require("luasnip").config.setup {
                enable_autosnippets = true,
                store_selection_keys = '<Tab>',
                region_check_events = 'InsertEnter',
                delete_check_events = 'InsertLeave'
            }
        end
    },
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "neovim/nvim-lspconfig",
    {
        'abecodes/tabout.nvim',
        lazy = false,
        config = function()
            require('tabout').setup {
                tabkey = '<C-l>',           -- tab out of brackets TODO: double bind with autopairs
                backwards_tabkey = '<C-h>', -- key to trigger backwards tabout, set to an empty string to disable
                act_as_tab = true,          -- shift content if tab out is not possible
                act_as_shift_tab = false,   -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                -- default_tab = '<C-t>',        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
                -- default_shift_tab = '<C-d>',  -- reverse shift default action,
                enable_backwards = true,
                completion = false,
                tabouts = {
                    { open = "'", close = "'" },
                    { open = '"', close = '"' },
                    { open = '`', close = '`' },
                    { open = '(', close = ')' },
                    { open = '[', close = ']' },
                    { open = '{', close = '}' }
                },
                ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                exclude = {} -- tabout will ignore these filetypes
            }
        end,
        dependencies = { -- These are optional
            "nvim-treesitter/nvim-treesitter",
            -- "L3MON4D3/LuaSnip"
            -- "hrsh7th/nvim-cmp"
        },
        opt = true,              -- Set this to true if the plugin is optional
        event = 'InsertCharPre', -- Set the event to 'InsertCharPre' for better compatibility
        priority = 1000,
    },
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    {
        "lentilus/fastex.nvim",
        enable = false,
        ft = { "latex", "tex" },
        dependencies = {
            "arne314/typstar",
            "lervag/vimtex",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local ls = require "luasnip"

            vim.api.nvim_create_autocmd("User", {
                pattern = "LuasnipPreExpand",
                callback = function()
                    vim.api.nvim_feedkeys(vim.api.nvim_eval('"\\<c-G>u"'), "i", true)
                end
            })

            ls.config.set_config {
                history = true,
                updateevents = "TextChanged,TextChangedI",
                enable_autosnippets = true,
                store_selection_keys = "<Tab>"
            }

            local ft = require("fastex")
            ft.setup()
            vim.keymap.set({ "n", "i", "s" }, "<M-j>", function() ft.smart_jump(1) end)
            vim.keymap.set({ "n", "i", "s" }, "<M-k>", function() ft.smart_jump(-1) end)
        end


    },
    -- {
    --     "iurimateus/luasnip-latex-snippets.nvim",
    --     -- vimtex isn't required if using treesitter
    --     dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    --     config = function()
    --         require 'luasnip-latex-snippets'.setup()
    --         -- or setup({ use_treesitter = true })
    --         require("luasnip").config.setup { enable_autosnippets = true }
    --
    --         local ls = require("luasnip")
    --         local utils = require("luasnip-latex-snippets.util.utils")
    --         local is_math = utils.with_opts(utils.is_math, false)   -- true to use treesitter
    --         local not_math = utils.with_opts(utils.not_math, false) -- true to use treesitter
    --     end,
    -- }
}, {
    "hrsh7th/nvim-cmp",
    enabled = true,
    commit = "b356f2c",
    pin = true,
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
        local cmp = require("cmp")
        local ls = require("luasnip")

        cmp.setup({
            snippet = {
                expand = function(args)
                    ls.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" }
            },
            mapping = {
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if ls.expand_or_jumpable() then
                        ls.expand_or_jump()
                    elseif cmp.visible() then
                        cmp.confirm { select = true }
                    else
                        fallback()
                    end
                end, {
                    "i",
                    "s",
                }),
                ['<S-Tab>'] = function(fallback)
                    if ls.jumpable(-1) then
                        ls.jump(-1)
                    elseif cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end,
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-Space>"] = cmp.mapping({
                    i = function()
                        if cmp.visible() then
                            cmp.abort()
                        else
                            cmp.complete()
                        end
                    end,
                    c = function()
                        if cmp.visible() then
                            cmp.close()
                        else
                            cmp.complete()
                        end
                    end,
                }),
            },
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities()
    end,
} }

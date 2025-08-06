-- Don't even ask me what goes on here. Read lsp-zero and mason documentation.
return { {
    "VonHeikemen/lsp-zero.nvim",
    branch = 'v4.x',
    config = function()
        vim.opt.signcolumn = 'yes'

        local lspconfig_defaults = require('lspconfig').util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lspconfig_defaults.capabilities,
            require('cmp_nvim_lsp').default_capabilities()
        )

        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gb', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>',
                    opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
        })
    end
},
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require('mason-tool-installer').setup {
                ensure_installed = {
                    -- you can pin a tool to a particular version
                    -- { 'golangci-lint',        version = 'v1.47.0' },
                    --
                    -- -- you can turn off/on auto_update per tool
                    -- { 'bash-language-server', auto_update = true },
                    --
                    -- -- you can do conditional installing
                    -- { 'gopls',                condition = function() return vim.fn.executable('go') == 1 end },
                    -- 'lua-language-server',
                    'nixfmt'
                },
                auto_update = false,
                run_on_start = true,
                start_delay = 3000,
                -- debounce_hours = 5,
                integrations = {
                    ['mason-lspconfig'] = true,
                    ['mason-null-ls'] = true,
                    ['mason-nvim-dap'] = true,
                },
            }
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = { 'jdtls', 'lua_ls', 'rust_analyzer', 'tinymist', 'nil_ls' },
                automatic_enable = {
                    exclude = {
                        "jdtls"
                    }
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                    ["tinymist"] = function()
                        require("lspconfig").tinymist.setup({
                            -- this is because https://github.com/neovim/neovim/issues/30675#issuecomment-2395272151
                            -- should be fixed in 0.10.3 though.
                            offset_encoding = "utf-8",
                            settings = {
                                formatterMode = "typstyle",
                            },
                        })
                    end,
                },
            })
        end,


    },
    {
        "mfussenegger/nvim-jdtls",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        ft = "java",
        config = function()
            -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
            -- depends on mason to autoinstall jdtls
            local install_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
            local launcher = vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
            local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

            -- Detect OS and set config directory
            local sysname = vim.fn.system("uname -s"):gsub("\n", "") -- "Linux", "Darwin" (macOS), etc.
            local config_dir
            if sysname == "Linux" then
                config_dir = install_path .. "/config_linux"
            elseif sysname == "Darwin" then
                config_dir = install_path .. "/config_mac"
            elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
                config_dir = install_path .. "/config_win"
            else
                vim.notify("Unsupported system for jdtls config", vim.log.levels.ERROR)
                return
            end

            -- Function to find the closest .iml file upwards and return its filename (or nil)
            local function find_closest_iml_name(startpath)
                local path = startpath or vim.fn.expand("%:p:h")
                while path and #path > 0 do
                    local iml_files = vim.fn.globpath(path, "*.iml", 0, 1)
                    if #iml_files > 0 then
                        -- Return just the file name (not full path)
                        return vim.fn.fnamemodify(iml_files[1], ":t")
                    end
                    local parent = vim.fn.fnamemodify(path, ":h")
                    if parent == path then break end
                    path = parent
                end
                return nil
            end

            -- Use in your setup:
            local iml_marker = find_closest_iml_name()
            local markers = {}

            if iml_marker then
                table.insert(markers, iml_marker)
            end
            -- Add standard project markers
            vim.list_extend(markers, { ".project", ".git", "mvnw", "gradlew" })

            local config = {
                -- for more info see:
                -- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#configuration-verbose
                cmd = {
                    'java',
                    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                    '-Dosgi.bundles.defaultStartLevel=4',
                    '-Declipse.product=org.eclipse.jdt.ls.core.product',
                    '-Dlog.protocol=true',
                    '-Dlog.level=ALL',
                    '-Xmx1g',
                    '--add-modules=ALL-SYSTEM',
                    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                    '-jar', launcher,
                    '-configuration', config_dir,
                    '-data', workspace_dir
                },
                root_dir = vim.fs.root(0, markers),

                settings = {
                    java = {
                    }
                },
                init_options = {
                    bundles = {}
                },
            }
            require('jdtls').start_or_attach(config)
        end
    },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    }

}

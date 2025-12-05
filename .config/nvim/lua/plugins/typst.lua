return { {
    "arne314/typstar",
    dir = "~/projects/typstar/",
    dev = true,
    ft = "typst",
    branch = "dev",
    dependencies = { {
        "nvim-treesitter/nvim-treesitter",
        enabled = true,
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = { "typst", "latex" } }
        end
    } },
    config = function()
        require('typstar').setup({
            snippets = {
                exclude = { 'ff', 'it', 'int' },
            },
        })

        vim.keymap.set("i", "<C-d>", "<Esc>:TypstarToggleSnippets<CR>a", { noremap = true })
        vim.keymap.set("n", "<C-d>", ":TypstarToggleSnippets<CR>", { noremap = true })
        vim.keymap.set("n", "<leader>ft", ":TypstarAnkiScan<CR>", { noremap = true })

        function isInMath(row, column)
            local utils = require('typstar.utils')
            local ts = vim.treesitter
            local ts_math_query = vim.treesitter.query.parse('typst', '(math) @math')
            local ts_string_query = ts.query.parse('typst', '(string) @string')
            local cursor = utils.get_cursor_pos()
            return utils.cursor_within_treesitter_query(ts_math_query, 0, 0, { row, column })
                and not utils.cursor_within_treesitter_query(ts_string_query, 0, 0, { row, column })
        end

        -- custom snippet definition
        local tp = require('typstar.autosnippets')
        local ls = require("luasnip")
        local visual = tp.visual
        local snip = tp.snip
        local math = tp.in_math
        local markup = tp.in_markup
        local i = ls.insert_node
        local s = ls.snippet
        local sn = ls.snippet_node
        local t = ls.text_node
        local d = ls.dynamic_node
        local indent = tp.leading_white_spaces

        function import_snippets(snippet_table)
            local snippet_results = {}
            for _, t in ipairs(snippet_table) do
                table.insert(snippet_results, snip_add(t[1], t[2]))
            end
            return snippet_results
        end

        function snip_add(snippet_type, tablename)
            local a = snippet_type
            if a == 'replace' then
                return tp.snip(unpack(tablename))
            elseif a == 'newline' then
                return tp.start_snip(unpack(tablename))
            elseif a == 'intonewline' then
                return tp.start_snip_in_newl(unpack(tablename))
            elseif a == 'manual' then
                return tp.snip_manual(unpack(tablename))
            end
        end

        function AlwaysTrue()
            return true
        end

        local function inTexMath()
            return vim.api.nvim_eval('vimtex#syntax#in_mathzone()') == 1
        end
        local function notInTexMath()
            return vim.api.nvim_eval('vimtex#syntax#in_mathzone()') ~= 1
        end
        -- format: {snippet_type, {trigger, replacement, table of dynamic replacement objects, condition }}
        local snippets = {
            { "newline",
                { 'frant',
                    '#frage[\n<>\t<>\n<>]\n<>#antwort[\n\t<><>\n<>]\n<>',
                    { indent(1), visual(1), indent(1), indent(1), i(2, "noch unbeantwortet"), indent(1), indent(1), indent(1) },
                    markup } },
            { "newline",
                { 'enum',
                    '#set enum(numbering: \"<>\")\n<>#enum(\n<>enum.item([\n<>\t<>\n<>]), <>\n<>)\n<><>',
                    { i(1, "1."), indent(1), indent(1),
                        indent(1), i(2), indent(1), i(3)
                    , indent(1), indent(1), i(4) }, markup } },

            { "intonewline",
                { 'enum',
                    '#set enum(numbering: \"<>\")\n<>#enum(\n<>enum.item([\n<>\t<>\n<>]), <>\n<>)\n<><>',
                    { i(1, "1."), indent(1), indent(1),
                        indent(1), i(2), indent(1), i(3)
                    , indent(1), indent(1), i(4) }, markup } },

            { "newline",
                { 'bsp',
                    '#beispiel[\n<>\t<>\n<>]\n<><>',
                    { indent(1), i(1), indent(1), indent(1), i(2), }, markup } },

            { "newline",
                { 'stz',
                    '#beispiel[\n<>\t<>\n<>]\n<><>',
                    { indent(1), i(1), indent(1), indent(1), i(2), }, markup } },

            { "newline",
                { 'item',
                    'enum.item([\n<>\t<>\n<>]), <>',
                    { indent(1), i(1), indent(1), i(2) }, function() return true end } },

            { "intonewline",
                { 'item',
                    'enum.item([\n<>\t<>\n<>]), <>',
                    { indent(1), i(1), indent(1), i(2) }, function() return true end } },

            -- reimplemented
            -- { "replace",     { '__', '_(<>) <>', { visual(1, '1'), i(2) }, math } },
            { "replace", { 'ff', '(<>) / (<>) <>', { visual(1, '1'), i(2), i(3) }, math } },
            { "replace", { 'it', 'integral_(<>) <> dif <> <>', { i(1), visual(2), i(3, 'x'), i(4) }, math } },
            { "replace", { 'int', 'integral_(<>)^(<>) <> dif <> <>', { i(1), i(2), visual(3), i(4, 'x'), i(5) }, math } },

            { "replace", { 'span', 'op("span") ', {}, math } },
            { "replace", { 'op', 'op("<>")<> ', { i(1), i(2) }, math } },

            { "replace", { 'spp', 'supset ', {}, math } },

            { "replace", { 'logg', 'log_(<>)(<>)<> ', { i(1), i(2), i(3) }, math } },

            { "replace", { 'ln', 'ln(<>)<> ', { i(1), i(2) }, math } },

            { "replace", { 'text', 'text("<>")<>', { i(1), i(2) }, math } },

            { "replace", { 'tt', 'wide &text("| <>")<>', { i(1), i(2) }, math } },

            { "replace", { 'ONO', 'cal(O)(<>)<>', { visual(1), i(2) }, math } },
            { "replace", { 'ONO', '$cal(O)(<>)$<>', { visual(1), i(2) }, markup } },
            --
            -- -- { "replace",     { '\\(', '(<>)<>', { i(1), i(2) } } },
            -- -- { "replace",     { '\\[', '[<>]<>', { i(1), i(2) } } },
            -- -- { "replace",     { '\\{', '{<>}<>', { i(1), i(2) } } },
            --
            { "replace", { 'mk', '$<>$<>', { i(1, '1+1'), i(2) }, markup } },

            { "replace", { 'bb', '*<>*<>', { i(1), i(2) }, markup } },

            { "replace", { 'qstr', '#strike[<>]<>', { i(1), i(2) }, markup } },

            { "replace", { 'ouset', 'attach(<>,t: <>)<>', { i(1, '\"middle\"'), i(2, '\"top\"'), i(3) }, math } },

            { "replace", { 'scr', 'attach(<>,bl: <>, br: <>)<>', { i(1, '\"main\"'), i(2, '\"left\"'), i(3, '\"right\"'), i(4) }, math } },

            { "replace", { '_pi', '$pi$', {}, markup } },
            --
            -- { "intonewline", { 'eqv', '<>\t & <>', { "<==>", tp.visual(1) }, math, '\\' } },
            --
            -- { "intonewline", { 'equ', '<>\t & <>', { "=", tp.visual(1) }, math, '\\' } }
            -- function M.visual(idx, default, line_prefix, indent_capture_idx)
            { "intonewline", { 'eqv', '\\ <> & <>', { i(1, "="), tp.visual(2) }, math, nil, {
                -- wordTrig = false,
                callbacks = {
                    [1] =
                    {
                        pre = function(snippet)
                            local cursor = vim.api.nvim_win_get_cursor(0)
                            local startrow = cursor[1] - 1

                            function getline(rownumber)
                                local line = vim.api.nvim_buf_get_lines(0, rownumber, rownumber + 1, false)[1]
                                if rownumber == startrow and snippet
                                    and snippet.captures
                                    and snippet.captures[1]
                                then
                                    line = line .. snippet.captures[1]
                                end
                                return line
                            end

                            local thisrow = startrow
                            local equalsFound
                            local lastNonWhiteSpace

                            while thisrow >= 1 do
                                local thisline = getline(thisrow)
                                if not thisline then
                                    thisrow = thisrow - 1
                                    goto continue
                                end
                                for i = #thisline, 1, -1 do
                                    local thisValue = thisline:sub(i, i)
                                    if thisValue == '&' and isInMath(thisrow, i) then
                                        return
                                    end
                                    -- if (thisValue == '\\' or thisValue == '$') and isInMath(thisrow, i) then
                                    if (thisValue == '\\' or thisValue == '$') then
                                        goto breky
                                    end
                                    if not equalsFound and (thisValue == '='
                                            or thisValue == '>'
                                            or thisValue == '<') and isInMath(thisrow, i) then
                                        equalsFound = { thisrow, i }
                                    elseif thisValue ~= ' ' then
                                        lastNonWhiteSpace = { thisrow, i }
                                    end
                                end
                                thisrow = thisrow - 1
                                ::continue::
                            end
                            ::breky::

                            local thisline
                            local outline
                            local column
                            if equalsFound then
                                row = equalsFound[1]
                                column = equalsFound[2]
                                thisline = getline(row)
                                outline = thisline:sub(1, column) ..
                                    " &" ..
                                    thisline:sub(column + 1)
                            else
                                row = lastNonWhiteSpace[1]
                                column = lastNonWhiteSpace[2]
                                thisline = getline(row)
                                outline = thisline:sub(1, column - 1) ..
                                    "& " ..
                                    thisline:sub(column)
                            end
                            print("Trying to replace: " .. thisline .. " with " .. outline)

                            vim.defer_fn(function()
                                vim.api.nvim_buf_set_lines(0, row, row + 1, false, { outline })
                            end, 1)
                        end
                    }

                }
            } } },
            -- { "intonewline", { 'eqv', '\\ <> & <>', { i(1, "<==>"), tp.visual(2) }, math } },

            { "replace",     { 'linc', 'LineComment(\n<>,\n<>[<>])<>', { visual(1), indent(1), i(2, 'comment'), i(3) }, AlwaysTrue } },
            { "intonewline", { 'dom', '$\t<>\n <>', { visual(1), visual(2) }, math } }
        }

        local latexsnips = {
            -- This is EXTREMELY scuffed. Only works because of autopairs
            -- No time to look into how I would even disable autopairs if there is luasnip precedence
            { "replace", { '""', '\\glqq{}\\<>grqq{}<>', { visual(1), i(2) }, AlwaysTrue } },
            { "replace", { '-co', '\\texttt{<>} <>', { i(1), i(2) }, AlwaysTrue } },
            { "replace", { 'kk', '^{<>} <>', { i(1), i(2) }, inTexMath, 1001, { wordTrig = false } } },
            { "replace", { 'mk', '\\(<>\\)<>', { i(1, '1+1'), i(2) }, notInTexMath } },
        }

        ls.add_snippets("tex", import_snippets(latexsnips))

        ls.add_snippets("typst", import_snippets(snippets))
    end
},
    {
        'chomosuke/typst-preview.nvim',
        lazy = false,
        ft = 'typst',
        version = '1.*',
        opts = {},
        config = function()
            require 'typst-preview'.setup {
                -- Setting this true will enable logging debug information to
                -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
                debug = false,

                -- Custom format string to open the output link provided with %s
                -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
                -- open_cmd = "qutebrowser --set window.title_format '' --set tabs.show never --set statusbar.show never %s & disown",
                open_cmd = "qutebrowser --set tabs.show never --set statusbar.show never %s & disown",
                -- open_cmd = ":",
                -- Custom port to open the preview server. Default is random.
                -- Example: port = 8000
                -- port = 12000,

                -- Enable partial rendering or not
                partial_rendering = true,

                -- Setting this to 'always' will invert black and white in the preview
                -- Setting this to 'auto' will invert depending if the browser has enable
                -- dark mode
                -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
                -- your choice of color inversion to images and everything else
                -- separately.
                invert_colors = 'never',

                -- Whether the preview will follow the cursor in the source file
                follow_cursor = true,

                -- Provide the path to binaries for dependencies.
                -- Setting this will skip the download of the binary by the plugin.
                -- Warning: Be aware that your version might be older than the one
                -- required.
                dependencies_bin = {
                    ['tinymist'] = 'tinymist',
                    ['websocat'] = nil
                },

                -- A list of extra arguments (or nil) to be passed to previewer.
                -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
                extra_args = nil,

                -- This function will be called to determine the root of the typst project
                get_root = function(path_of_main_file)
                    local root = os.getenv 'TYPST_ROOT'
                    if root then
                        return root
                    end
                    return vim.fn.fnamemodify(path_of_main_file, ':p:h')
                end,

                -- This function will be called to determine the main file of the typst
                -- project.
                get_main_file = function(path_of_buffer)
                    return path_of_buffer
                end,
            }


            -- this requires i3 and quitebrowser to function. This is an auto-open
            -- and resive of the typst live preview of tinymist through typst-preview.

            local function autoResizeBrowser()
                local browser_class = "qutebrowser"
                local terminal_class = "Alacritty"

                -- Check required commands exist
                if vim.fn.executable('i3-msg') ~= 1 then
                    vim.notify('i3-msg not found in PATH', vim.log.levels.ERROR)
                    return
                end
                if vim.fn.executable('xdotool') ~= 1 then
                    vim.notify('xdotool not found in PATH', vim.log.levels.ERROR)
                    return
                end
                if vim.fn.executable(browser_class) ~= 1 then
                    vim.notify(browser_class .. ' not found in PATH', vim.log.levels.ERROR)
                    return
                end
                if vim.fn.executable(terminal_class:lower()) ~= 1 then -- Match actual binary name
                    vim.notify(terminal_class .. ' not found in PATH', vim.log.levels.ERROR)
                    return
                end

                local function get_window_id_by_class(class)
                    local handle = io.popen("xdotool search --onlyvisible --class " .. class)
                    local result = handle:read("*a"):gsub("%s+", "")
                    handle:close()
                    return result
                end

                local function focus_window(window_id)
                    if window_id and window_id ~= "" then
                        os.execute("xdotool windowactivate " .. window_id)
                    end
                end

                -- Async window detection with timeout
                local check_timer = vim.loop.new_timer()
                local attempts = 0
                local max_attempts = 25 -- 200ms * 25 = 5 seconds

                local function check_browser_window()
                    local browser_window = get_window_id_by_class(browser_class)
                    local terminal_window = get_window_id_by_class(terminal_class)

                    if browser_window ~= "" then
                        check_timer:close()
                        focus_window(browser_window)
                        os.execute("i3-msg resize set width 750 px")
                        focus_window(terminal_window)
                        -- local tprev = require('typst-preview')
                        -- tprev.sync_with_cursor()
                    elseif attempts >= max_attempts then
                        check_timer:close()
                        vim.notify('Browser window not detected within 5 seconds', vim.log.levels.WARN)
                    end
                    attempts = attempts + 1
                end

                -- Start async checks
                -- vim.cmd("TypstPreview")
                check_timer:start(200, 200, vim.schedule_wrap(check_browser_window))


                vim.api.nvim_set_keymap('n', '<S-F10>', ':TypstPreviewToggle<CR>', { noremap = true, silent = true })

                vim.api.nvim_create_autocmd("BufUnload", {
                    buffer = 0,
                    callback = function()
                        vim.cmd("TypstPreviewStop")
                        os.execute("pkill -f" .. browser_class)
                        os.execute("pkill -f" .. tinymist)
                        if check_timer then
                            check_timer:close()
                        end
                    end,
                })
            end

            vim.api.nvim_create_user_command('TypstPreviewAutoResize', function()
                vim.cmd('TypstPreview')
                autoResizeBrowser()
            end, {})

            -- comment following to disable
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "typst",
                callback = function()
                    vim.opt_local.wrap = true
                    vim.opt_local.linebreak = true
                    vim.bo.commentstring = "// %s"
                    vim.cmd('TypstPreviewAutoResize')
                end,
            })
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*.typst",
                callback = function()
                    vim.cmd('TypstPreviewAutoResize')
                end,
            })
        end
    } }

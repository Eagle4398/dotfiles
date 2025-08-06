local config_dir = vim.fn.stdpath("config")
local venv_path = config_dir .. "/.venv"
local bootstrap_py_path = config_dir .. "/bootstrap_py.sh"

-- bootstrap reproducible non-system python envirnoment using uv
-- depends on clang unfortunately
if vim.fn.isdirectory(venv_path) == 0 then
    if vim.fn.filereadable(bootstrap_py_path) == 1 then
        local exit_code = os.execute(bootstrap_py_path)
        if exit_code ~= 0 then
            error("bootstrap.sh failed with exit code " .. tostring(exit_code))
        end
    else
        print("Bootstrap script not found: " .. bootstrap_py_path)
    end
end
vim.g.python3_host_prog = config_dir .. "/.venv/bin/python3"

vim.loader.enable()

require("egloo.remap")
require("egloo.autocmd")
require("egloo.options")
require("config.lazy")

-- Use system clipboard for yank and paste
vim.o.clipboard = "unnamedplus"

-- spellcheck
vim.opt_local.spell = true
vim.opt.spelllang = { "en_us", "de_de" }

-- local ls = require("luasnip")

vim.api.nvim_set_keymap("n", "j", "v:count ? 'j' : 'gj'", { noremap = true, expr = true })
vim.api.nvim_set_keymap("n", "k", "v:count ? 'k' : 'gk'", { noremap = true, expr = true })

-- this should be its own plugin but this is just some LLM mess
-- for dynamically selecting code for latex code quoting. as it's implemented
-- now it's basically: if you have such a line under your cursor
-- \lstinputlisting[firstnumber=25,firstline=31,lastline=34]{Set.java}
-- and you press leader fc then it creates a temporary focused buffer with the 
-- Set.java. In this you can go into visual select line mode and after you press
-- leader ac it will go back to the original buffer, close the temporary one
-- and correctly insert the correct line numbers, of your selection. If you are 
-- forced to write latex documentation for code, and you want to quote code this 
-- saves so much time.

_G.latex_code_selection = {
    orig_buf = nil,
    orig_lnum = nil,

    parse_statement = function(line)
        if not line:find("\\lstinputlisting") then return nil end

        local filename = line:match("{([^}]+)}")
        local firstnumber = line:match("firstnumber=(%d+)")
        local firstline = line:match("firstline=(%d+)")
        local lastline = line:match("lastline=(%d+)")

        if filename and firstnumber and firstline and lastline then
            return firstnumber, firstline, lastline, filename
        end
        return nil
    end,

    update_statement = function(bufnr, lnum, firstline, lastline)
        local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
        local intermediate_line = line:gsub(
            "firstline=%d+,lastline=%d+",
            string.format("firstline=%d,lastline=%d", firstline, lastline)
        )
        local new_line = intermediate_line:gsub(
            "firstnumber=%d+",
            string.format("firstnumber=%d", firstline)
        )
        vim.api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, false, { new_line })
    end,

    process_selection = function()
        if not _G.latex_code_selection.orig_buf or not _G.latex_code_selection.orig_lnum then
            print("Error: Original buffer information is missing.")
            return
        end

        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")

        local code_buf = vim.api.nvim_get_current_buf()

        vim.cmd("buffer " .. _G.latex_code_selection.orig_buf)

        _G.latex_code_selection.update_statement(
            _G.latex_code_selection.orig_buf,
            _G.latex_code_selection.orig_lnum,
            start_line,
            end_line
        )

        vim.cmd("write")

        vim.cmd("bdelete " .. code_buf)
    end,

    setup_code_buffer = function(filename)
        vim.cmd("write")

        vim.cmd("edit " .. filename)

        vim.cmd([[
      command! -buffer -range ProcessCodeSelection lua _G.latex_code_selection.process_selection()
    ]])

        -- Map <leader>ac in visual mode to the command
        vim.cmd([[
      vnoremap <buffer> <leader>ac :<C-U>ProcessCodeSelection<CR>
    ]])

        print("Select lines and press <leader>ac to update LaTeX statement.")
    end,

    process_current_line = function()
        local lnum = vim.fn.line('.')
        local line = vim.api.nvim_get_current_line()

        local firstnumber, firstline, lastline, filename = _G.latex_code_selection.parse_statement(line)

        if not filename then
            print("No lstinputlisting statement found on this line.")
            return
        end

        _G.latex_code_selection.orig_buf = vim.api.nvim_get_current_buf()
        _G.latex_code_selection.orig_lnum = lnum

        _G.latex_code_selection.setup_code_buffer(filename)
    end
}

vim.cmd([[
  command! ProcessLstInputListing lua _G.latex_code_selection.process_current_line()
]])

vim.api.nvim_set_keymap('n', '<leader>fc', ':ProcessLstInputListing<CR>', {
    noremap = true,
    silent = true,
    desc = "Process lstinputlisting and open file for selection"
})

-----------------------------


return
{
    {
        "lervag/vimtex",
        init = function()
            vim.g.tex_flavor = 'latex'
            vim.g.vimtex_view_method = 'zathura'
            vim.g.vimtex_quickfix_mode = 0
            vim.g.conceallevel = 2
        end,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "tex",
                callback = function()
                    vim.opt_local.wrap = true
                    vim.opt_local.linebreak = true
                    vim.bo.commentstring = "% %s"
                    vim.api.nvim_set_keymap('n', '<S-F10>', ':VimtexCompile<CR>', { noremap = true, silent = true })
                end,
            })
        end
    }
}

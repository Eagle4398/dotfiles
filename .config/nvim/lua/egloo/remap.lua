-- leader is space
vim.g.mapleader = " "

-- go into file browser
vim.keymap.set("n", "<leader>pv", ":Ex<CR>")

-- CTRL q to force close current buffer
vim.api.nvim_set_keymap("i", '<C-q>', '<Esc>:q!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", '<C-q>', '<Esc>:q!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", '<C-q>', '<Esc>:q!<CR>', { noremap = true, silent = true })

-- Tried setting a key to correct last typo, but doesn't seem to work like it should
-- TODO 'spell checking is not possible'  
vim.keymap.set('n', '<leader>ft', '[sz=1<CR>', { noremap = true, silent = true })

-- CTRL S to save the current buffer because I can't get rid of the windows habit
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })

-- I mistype way too often
vim.api.nvim_create_user_command('W', 'w', {})


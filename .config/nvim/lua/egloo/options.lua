-- Mainly copied off ThePrimeagen

-- default cursor style
vim.opt.guicursor = ""

-- current absolute line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- tab to spaces
vim.opt.expandtab = true

vim.opt.smartindent = true

-- no line wrapping unless specified
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

-- for undo-history
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- don't highlight all matches using pattern
vim.opt.hlsearch = false
-- jump to first occurance using pattern
vim.opt.incsearch = true

-- 24bit instead of 8bit colors
vim.opt.termguicolors = true

-- keeps 8 lines visible above cursor and below when scrolling up or down.
-- (otherwise you can't see what you are scrolling to.)
vim.opt.scrolloff = 8

-- When using breakpoints / viewing git commits a column is added.
-- This setting makes it persistent such that the code position never shifts.
vim.opt.signcolumn = "yes"

-- didn't need to use it yet but may be relevant doing js
vim.opt.isfname:append("@-@")

-- who wants LSP  updates every 4 seconds? (default = 4000)
-- Mainly this is for autocomplete IIRC
vim.opt.updatetime = 50

-- creates a visual column at character 80 otherwise this makes code 
-- unreadable.
vim.opt.colorcolumn = "80"

-- if supported
vim.opt.smoothscroll = true

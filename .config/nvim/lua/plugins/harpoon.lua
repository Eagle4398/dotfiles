-- I really need to fix the keybindings 
-- quick switching between files
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        -- REQUIRED
        harpoon:setup()
        -- REQUIRED

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<C-'>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<C-,>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<C-.>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<C-p>", function() harpoon:list():select(4) end)

        -- these don't really work
        -- -- Toggle previous & next buffers stored within Harpoon list
        -- vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
        -- vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    end
}

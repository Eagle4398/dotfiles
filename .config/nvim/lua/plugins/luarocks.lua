-- never got luarocks to work
return {
    {
        "vhyrro/luarocks.nvim",
        enable = false;
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        config = true,
        -- opts = { rocks = { "jsregexp" } }
    }

}

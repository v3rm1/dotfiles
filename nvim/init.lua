-- Load lua tables 
require("options")
require("keymaps")
require("autocmds")

-- Install Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    defaults = { lazy = false },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true, notify = false },
    change_detection = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                            },
        },
    },
})

-- Set colorsheme
require("catppuccin").load()

-- Enable lsp
local lsp = require("lsp")
lsp.enable()

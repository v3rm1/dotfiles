-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.confirm = true
vim.opt.scrolloff = 10
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = "a"

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.showbreak = "↪ "
vim.opt.breakindent = true
vim.opt.laststatus = 3
vim.opt.sessionoptions:remove{"terminal"}

vim.opt.foldlevel = 99
vim.opt.termguicolors = true

vim.cmd("packadd nvim.undotree")

-- Experimental new UI
require("vim._core.ui2").enable({
    enable = true,
})

require("keymaps")
require("autocmds")
require("plugins")
require("lsp_setup").setup()

-- Remove inactive plugins
vim.api.nvim_create_user_command("Packsync", function()
    local inactive = vim.iter(vim.pack.get())
        :filter(function(x)
            return not x.active
        end)
        :map(function(x)
            return x.spec.name
        end)
        :totable()
    if #inactive == 0 then
        vim.notify("PackSync: nothing to remove")
        return
    end
    vim.notify("PackSync: removing " .. table.concat(inactive, ", "))
    vim.pack.del(inactive)
end, { desc = "Remove inactive pack plugins" })

vim.cmd("colorscheme dark_pastel")

vim.loader.enable()

-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.showmode = false
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftround = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.opt.laststatus = 3
vim.opt.winbar = "%=%m %f"
vim.opt.sessionoptions:remove({ "terminal" })

vim.opt.foldlevel = 99
vim.opt.termguicolors = true

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
    float = {
        border = "rounded",
        source = "if_many",
    },
    severity_sort = true,
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({
                bufnr = bufnr,
                scope = "cursor",
                focus = false,
            })
        end,
    },
})

vim.cmd("packadd nvim.undotree")

-- Experimental new UI
require("vim._core.ui2").enable({
    enable = true,
})

require("keymaps")
require("autocmds")
require("lsp_setup").setup()
require("statusline")
require("plugins")

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
vim.cmd("colorscheme tokyonight")

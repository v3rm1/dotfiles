vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/tpope/vim-sleuth",
    "https://github.com/folke/lazydev.nvim",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/folke/snacks.nvim",
    "https://github.com/folke/trouble.nvim",
    "https://github.com/folke/persistence.nvim",
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/stevearc/conform.nvim",
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("1.*"),
    },
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/NeogitOrg/neogit",
    "https://github.com/smjonas/inc-rename.nvim",
    "https://github.com/j-hui/fidget.nvim",
    "https://github.com/christoomey/vim-tmux-navigator",
    "https://github.com/lervag/vimtex",
    "https://github.com/hat0uma/csvview.nvim",
    "https://github.com/mrcjkb/rustaceanvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/zbirenbaum/copilot.lua",
    "https://github.com/NickvanDyke/opencode.nvim",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/mfussenegger/nvim-dap-python",
})

-- Plugin configs
require("plugins.snacks_setup")
require("plugins.oil_setup")
require("plugins.treesitter_setup")
require("plugins.mini_setup")
require("plugins.blink_setup")
require("plugins.csv_setup")
require("plugins.tex_setup")
require("plugins.git_setup")
require("plugins.conform_setup")
require("plugins.markdown_setup")
require("plugins.mason_setup")
require("plugins.ai_setup")
require("plugins.dap_setup")

require("lazydev").setup({
    library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
    },
})

require("which-key").setup({
    preset = "helix",
    delay = 300,
    spec = {
        { "<leader>u", group = "+toggle" },
        { "<leader>g", group = "+git" },
        { "<leader>q", group = "+session" },
        { "<leader>f", group = "+find/fuzzy" },
        { "<leader>c", group = "+code" },
        { "<leader>s", group = "+search" },
        { "<leader>l", group = "+lsp" },
        { "<leader>d", group = "+debug" },
        { "gl", group = "+lsp_snacks" },
        { "gr", group = "+lsp_default" },
        { "<localleader>l", group = "+vimtex" },
    },
})

vim.keymap.set("n", "<leader>?", function()
    require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

require("inc_rename").setup({ preview_empty_name = true })
vim.keymap.set("n", "<leader>cr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

require("fidget").setup({})

vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "tmux left" })
vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "tmux down" })
vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "tmux up" })
vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "tmux right" })
vim.keymap.set("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "tmux previous" })

require("persistence").setup({})
vim.keymap.set("n", "<leader>qs", function()
    require("persistence").load()
end, { desc = "Restore Session" })
vim.keymap.set("n", "<leader>qS", function()
    require("persistence").select()
end, { desc = "Select Session" })
vim.keymap.set("n", "<leader>ql", function()
    require("persistence").load({ last = true })
end, { desc = "Restore Last Session" })
vim.keymap.set("n", "<leader>qd", function()
    require("persistence").stop()
end, { desc = "Don't Save Session" })

require("trouble").setup({ focus = true })
vim.keymap.set("n", "<leader>lX", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Diagnostics" })
vim.keymap.set(
    "n",
    "<leader>lx",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    { desc = "Toggle Diagnostics (buf)" }
)
vim.keymap.set("n", "<leader>ll", "<cmd>Trouble lsp toggle focus=false<cr>", { desc = "Toggle LSP Def/Ref" })
vim.keymap.set("n", "<leader>lL", "<cmd>Trouble loclist toggle<cr>", { desc = "Toggle Loc List" })
vim.keymap.set("n", "<leader>lq", "<cmd>Trouble qflist toggle<cr>", { desc = "Toggle Quickfix List" })

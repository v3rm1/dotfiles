local gh = function(repo)
    return "https://github.com/" .. repo
end

-- Loaded at startup: UI, LSP/treesitter core, editing essentials.
vim.pack.add({
    gh("neovim/nvim-lspconfig"),
    gh("tpope/vim-fugitive"),
    gh("tpope/vim-sleuth"),
    gh("echasnovski/mini.nvim"),
    gh("lewis6991/gitsigns.nvim"),
    gh("stevearc/oil.nvim"),
    gh("stevearc/conform.nvim"),
    gh("nvim-treesitter/nvim-treesitter"),
    gh("nvim-treesitter/nvim-treesitter-textobjects"),
    gh("nvim-treesitter/nvim-treesitter-context"),
    gh("christoomey/vim-tmux-navigator"),
    gh("lervag/vimtex"),
    gh("mrcjkb/rustaceanvim"),
    gh("nvim-lua/plenary.nvim"),
    gh("folke/tokyonight.nvim"),
})

-- Installed but loaded on demand through lua/lazyload.lua (see specs below).
vim.pack.add({
    gh("folke/lazydev.nvim"),
    gh("folke/which-key.nvim"),
    gh("ibhagwan/fzf-lua"),
    gh("folke/trouble.nvim"),
    gh("folke/persistence.nvim"),
    { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
    gh("rafamadriz/friendly-snippets"),
    gh("NeogitOrg/neogit"),
    gh("sindrets/diffview.nvim"),
    gh("smjonas/inc-rename.nvim"),
    gh("j-hui/fidget.nvim"),
    gh("hat0uma/csvview.nvim"),
    gh("MeanderingProgrammer/render-markdown.nvim"),
    gh("3rd/image.nvim"),
    gh("lukas-reineke/indent-blankline.nvim"),
    gh("mason-org/mason.nvim"),
    gh("mfussenegger/nvim-dap"),
    gh("rcarriga/nvim-dap-ui"),
    gh("nvim-neotest/nvim-nio"),
    gh("mfussenegger/nvim-dap-python"),
    gh("coder/claudecode.nvim"),
    gh("jmbuhr/otter.nvim"),
    gh("quarto-dev/quarto-nvim"),
    gh("jalvesaq/zotcite"),
    gh("MagicDuck/grug-far.nvim"),
    gh("stevearc/overseer.nvim"),
}, { load = function() end })

local lazy = require("lazyload")

-- Startup plugin configs
require("native.bigfile")
require("native.toggle")
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
vim.keymap.set("n", "<leader>gg", function()
    require("native.lazygit").open()
end, { desc = "Lazygit" })
require("plugins.oil_setup")
require("plugins.treesitter_setup")
require("plugins.tex_setup")
require("plugins.conform_setup")
require("plugins.rust_setup")

-- Keymaps and command stubs here, plugin setup on first use
require("plugins.fzf_setup")
require("plugins.claude_setup")
require("plugins.git_setup")
require("plugins.mason_setup")
require("plugins.dap_setup")
require("plugins.grug_far_setup")
require("plugins.overseer_setup")

-- Right after the first screen
lazy.add({ defer = true, setup = "plugins.mini_setup" })
lazy.add({ defer = true, plugins = { "indent-blankline.nvim" }, setup = "plugins.ibl_setup" })
lazy.add({
    defer = true,
    plugins = { "which-key.nvim" },
    modules = { "which-key" },
    setup = function()
        require("which-key").setup({
            preset = "helix",
            delay = 300,
            spec = {
                { "<leader>a", group = "+ai" },
                { "<leader>b", group = "+buffer" },
                { "<leader>u", group = "+toggle" },
                { "<leader>g", group = "+git" },
                { "<leader>q", group = "+session" },
                { "<leader>f", group = "+find/fuzzy" },
                { "<leader>c", group = "+code" },
                { "<leader>s", group = "+search" },
                { "<leader>l", group = "+lsp" },
                { "<leader>d", group = "+debug" },
                { "<leader>o", group = "+tasks" },
                { "<leader>z", group = "+zotero" },
                { "<localleader>q", group = "+quarto" },
                { "gl", group = "+lsp" },
                { "gr", group = "+lsp_default" },
                { "<localleader>l", group = "+vimtex" },
            },
        })
    end,
})
vim.keymap.set("n", "<leader>?", function()
    require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

lazy.add({
    defer = true,
    plugins = { "persistence.nvim" },
    modules = { "persistence" },
    setup = function()
        require("persistence").setup({})
    end,
})
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

-- Completion: before the first buffer's LSP clients start, so they get
-- blink's capabilities
lazy.add({
    event = { "BufReadPre", "BufNewFile", "InsertEnter", "CmdlineEnter" },
    plugins = { "friendly-snippets", "blink.cmp" },
    modules = { "blink" },
    setup = "plugins.blink_setup",
})

lazy.add({
    event = "LspAttach",
    plugins = { "fidget.nvim" },
    modules = { "fidget" },
    setup = function()
        require("fidget").setup({})
    end,
})

lazy.add({
    plugins = { "inc-rename.nvim" },
    modules = { "inc_rename" },
    cmd = { "IncRename" },
    setup = function()
        require("inc_rename").setup({ preview_empty_name = true })
    end,
})
vim.keymap.set("n", "<leader>cr", function()
    require("inc_rename") -- load first so the command preview works
    return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

lazy.add({
    plugins = { "trouble.nvim" },
    modules = { "trouble" },
    cmd = { "Trouble" },
    setup = function()
        require("trouble").setup({ focus = true })
    end,
})
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

-- Filetype tools: only loaded when a matching buffer opens
lazy.add({
    ft = "lua",
    plugins = { "lazydev.nvim" },
    modules = { "lazydev" },
    setup = function()
        require("lazydev").setup({
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        })
    end,
})
lazy.add({
    ft = { "csv", "tsv" },
    plugins = { "csvview.nvim" },
    modules = { "csvview" },
    cmd = { "CsvViewToggle", "CsvViewEnable", "CsvViewDisable" },
    setup = "plugins.csv_setup",
})
lazy.add({
    ft = { "markdown", "quarto" },
    plugins = { "render-markdown.nvim" },
    modules = { "render-markdown" },
    cmd = { "RenderMarkdown" },
    setup = "plugins.markdown_setup",
})
lazy.add({
    ft = { "markdown", "tex" },
    plugins = { "image.nvim" },
    modules = { "image" },
    setup = "plugins.image_setup",
})
lazy.add({
    ft = "quarto",
    plugins = { "otter.nvim", "quarto-nvim" },
    modules = { "quarto", "otter" },
    cmd = { "QuartoPreview", "QuartoClosePreview", "QuartoActivate" },
    setup = "plugins.quarto_setup",
})
lazy.add({
    ft = { "markdown", "pandoc", "quarto", "rmd" },
    plugins = { "zotcite" },
    modules = { "zotcite" },
    setup = "plugins.zotcite_setup",
})


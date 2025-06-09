return {
    { "neovim/nvim-lspconfig", lazy = false },
    { "tpope/vim-sleuth" },
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},
    },
    { "j-hui/fidget.nvim", event = { "LspAttach" }, opts = {} },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        opts = {
            preview_empty_name = true,
        },
        keys = {
            {
                "<leader>cr",
                function()
                    return ":IncRename " .. vim.fn.expand("<cword>")
                end,
                expr = true,
                desc = "Inc Rename",
            },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
            delay = 300,
            -- filter = function(mapping)
            --     return mapping.desc and mapping.desc ~= ""
            -- end,
            spec = {
                { "<leader>u", group = "+[t]oggle" },
                { "<leader>g", group = "+git" },
                { "<leader>q", group = "+session" },
                { "<leader>f", group = "+[f]ind" },
                { "<leader>c", group = "+code" },
                { "<leader>s", group = "+search" },
                { "<leader>t", group = "+treesitter" },
                { "<leader>d", group = "+debug" },
                { "<localleader>f", group = "+run [f]ile" },
                { "<localleader>l", group = "+vimtex" },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    {
        "mbbill/undotree",
        -- event = "VeryLazy",
        cmd = { "UndotreeToggle" },
        keys = {
            {
                "<leader>uu",
                vim.cmd.UndotreeToggle,
                desc = "Toggle undotree",
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },
}

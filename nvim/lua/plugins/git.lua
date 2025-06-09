return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                vim.keymap.set("n", "[h", function()
                    gitsigns.nav_hunk("prev")
                end, { desc = "Previous Githunk", buffer = bufnr })
                vim.keymap.set("n", "]h", function()
                    gitsigns.nav_hunk("next")
                end, { desc = "Next Githunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview Hunk", buffer = bufnr })
            end,
            preview_config = {
                -- Options passed to nvim_open_win
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
                title = "Preview Hunk",
            },
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim",
        },
        cmd = { "Neogit" },
        keys = {
            {
                "<leader>gg",
                function()
                    require("neogit").open()
                end,
                desc = "Neogit",
            },
        },
        config = function()
            require("neogit").setup({
                integrations = {
                    diffview = true,
                    telescope = true,
                },
                commit_editor = {
                    kind = "auto",
                    staged_diff_split_kind = "auto",
                },
            })
        end,
    },
}

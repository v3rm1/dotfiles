local lazy = require("lazyload")
lazy.add({
    plugins = { "diffview.nvim" },
    modules = { "diffview" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh" },
})
lazy.add({
    plugins = { "neogit" },
    modules = { "neogit" },
    cmd = { "Neogit" },
    setup = function()
        require("neogit").setup({
            commit_editor = {
                kind = "auto",
                staged_diff_split_kind = "auto",
            },
        })
    end,
})

vim.keymap.set("n", "<leader>gg", function()
    require("neogit").open()
end, { desc = "Neogit" })

vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   { desc = "Git repo history" })

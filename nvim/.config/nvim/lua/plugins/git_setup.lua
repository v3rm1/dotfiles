require("neogit").setup({
    commit_editor = {
        kind = "auto",
        staged_diff_split_kind = "auto",
    },
})

vim.keymap.set("n", "<leader>gg", function()
    require("neogit").open()
end, { desc = "Neogit" })

vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   { desc = "Git repo history" })

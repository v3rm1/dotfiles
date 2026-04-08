require("neogit").setup({
    commit_editor = {
        kind = "auto",
        staged_diff_split_kind = "auto",
    },
})

vim.keymap.set("n", "<leader>gg", function()
    require("neogit").open()
end, { desc = "Neogit" })

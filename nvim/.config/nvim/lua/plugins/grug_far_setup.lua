-- grug-far: project-wide search and replace (ripgrep) with a live preview buffer.
require("lazyload").add({
    plugins = { "grug-far.nvim" },
    modules = { "grug-far" },
    cmd = { "GrugFar", "GrugFarWithin" },
    setup = function()
        require("grug-far").setup({})
    end,
})

vim.keymap.set("n", "<leader>sR", function()
    require("grug-far").open()
end, { desc = "Search and replace (project)" })
vim.keymap.set("x", "<leader>sR", function()
    require("grug-far").with_visual_selection()
end, { desc = "Search and replace selection (project)" })
vim.keymap.set("n", "<leader>sF", function()
    require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search and replace (file)" })

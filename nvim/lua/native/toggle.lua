local map = vim.keymap.set

map("n", "<leader>us", function()
    vim.o.spell = not vim.o.spell
end, { desc = "Toggle Spelling" })

map("n", "<leader>uw", function()
    vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle Wrap" })

map("n", "<leader>uL", function()
    vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle Relative Number" })

map("n", "<leader>uc", function()
    vim.o.conceallevel = vim.o.conceallevel == 0 and 2 or 0
end, { desc = "Toggle Conceal" })

map("n", "<leader>ud", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })

map("n", "<leader>ul", function()
    vim.o.number = not vim.o.number
end, { desc = "Toggle Line Number" })

map("n", "<leader>uT", function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.treesitter.highlighter.active[buf] then
        vim.treesitter.stop(buf)
    else
        vim.treesitter.start(buf)
    end
end, { desc = "Toggle Treesitter" })

map("n", "<leader>ub", function()
    vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, { desc = "Toggle Dark Background" })

map("n", "<leader>uh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle Inlay Hints" })

map("n", "<leader>ug", function()
    vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable
end, { desc = "Toggle Indent Scope" })

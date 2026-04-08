local Snacks = require("snacks")

Snacks.setup({
    bigfile = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    words = { enabled = false },
    image = {
        enabled = true,
        math = { enabled = false },
        doc = { inline = false },
    },
    styles = {
        snacks_image = {
            relative = "editor",
            row = 1,
            col = 99999,
            title = "Snacks Image",
            focusable = true,
        },
    },
    picker = { enabled = true },
    statuscolumn = { enabled = false },
    dashboard = { enabled = false },
})

-- Picker keymaps
vim.keymap.set("n", "<leader><space>", function()
    Snacks.picker.smart({
        multi = { "buffers", "recent", "files" },
        hidden = true,
    })
end, { desc = "Find buffers and files" })
vim.keymap.set("n", "<leader>/", function()
    Snacks.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fb", function()
    Snacks.picker.buffers()
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fc", function()
    Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function()
    Snacks.picker.files({ hidden = true })
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
    Snacks.picker.git_files()
end, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fr", function()
    Snacks.picker.recent()
end, { desc = "Find Recent Files" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
    Snacks.picker.grep_word()
end, { desc = "Grep Word" })
vim.keymap.set("n", "<leader>sa", function()
    Snacks.picker.autocmds()
end, { desc = "Autocmds" })
vim.keymap.set("n", "<leader>sb", function()
    Snacks.picker.lines()
end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sc", function()
    Snacks.picker.commands()
end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", function()
    Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", function()
    Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>sh", function()
    Snacks.picker.help()
end, { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", function()
    Snacks.picker.highlights()
end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>sk", function()
    Snacks.picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sm", function()
    Snacks.picker.marks()
end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", function()
    Snacks.picker.man()
end, { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sl", function()
    Snacks.picker.loclist()
end, { desc = "Location List" })
vim.keymap.set("n", "<leader>sq", function()
    Snacks.picker.qflist()
end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>ss", function()
    Snacks.picker.lsp_symbols()
end, { desc = "Lsp symbols" })
vim.keymap.set("n", "<leader>sS", function()
    Snacks.picker.lsp_workspace_symbols()
end, { desc = "Lsp workspace symbols" })

-- Toggles
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle
    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map("<leader>uc")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.zen():map("<leader>uz")

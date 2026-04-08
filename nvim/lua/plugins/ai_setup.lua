require("copilot").setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = false, -- handled by nvim-cmp / blink.cmp
            next = "<M-n>",
            prev = "<M-p>",
            accept_word = "<M-w>",
            accept_line = "<M-l>",
            dismiss = "<M-e>",
        },
    },
    panel = { enabled = false },
    filetypes = {
        markdown = true,
        help = true,
    },
})

local oc = require("opencode")
vim.keymap.set({ "n", "x" }, "<M-a>", function()
    oc.ask("@this: ", { submit = true })
end, { desc = "Ask opencode" })
vim.keymap.set({ "n", "x" }, "<leader>oc", function()
    oc.command("agent.cycle")
end, { desc = "Cycle opencode agent" })
vim.keymap.set({ "n", "x" }, "<leader>os", function()
    oc.select()
end, { desc = "Execute opencode action" })
vim.keymap.set("t", "<leader>ot", function()
    oc.toggle()
end, { desc = "Toggle opencode" })
vim.keymap.set({ "n", "x" }, "go", function()
    return oc.operator("@this ")
end, { desc = "Add range to opencode", expr = true })
vim.keymap.set({ "n", "x" }, "goo", function()
    return oc.operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })
vim.keymap.set("n", "<M-u>", function()
    oc.command("session.half.page.up")
end, { desc = "Scroll opencode up" })
vim.keymap.set("n", "<M-d>", function()
    oc.command("session.half.page.down")
end, { desc = "Scroll opencode down" })

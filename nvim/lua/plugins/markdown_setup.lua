require("render-markdown").setup({
    file_types = { "markdown", "quarto" },
    completions = {
        blink = { enabled = true },
        lsp = { enabled = true },
    },
    code = {
        width = "block",
        border = "thick",
    },
    win_options = {
        conceallevel = {
            rendered = 2,
        },
    },
})

vim.keymap.set("n", "<leader>um", function()
    local m = require("render-markdown")
    if require("render-markdown.state").enabled then
        m.disable()
    else
        m.enable()
    end
end, { desc = "Toggle Render Markdown" })

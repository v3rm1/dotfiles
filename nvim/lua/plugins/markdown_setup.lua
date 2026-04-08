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

Snacks.toggle({
    name = "Render Markdown",
    get = function()
        return require("render-markdown.state").enabled
    end,
    set = function(enabled)
        local m = require("render-markdown")
        if enabled then
            m.enable()
        else
            m.disable()
        end
    end,
}):map("<leader>um")

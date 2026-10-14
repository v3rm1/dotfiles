-- quarto-nvim: preview and LSP inside code chunks of .qmd files. otter.nvim
-- gives each chunk language its own hidden LSP buffer (ruff/ty for python etc).
-- No REPL plugin installed, so the code runner stays off.
vim.treesitter.language.register("markdown", { "quarto", "rmd" })

require("quarto").setup({
    lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "python", "bash", "lua", "r", "julia" },
        diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
        },
        completion = {
            enabled = true,
        },
    },
    codeRunner = {
        enabled = false,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("my_quarto", { clear = true }),
    pattern = "quarto",
    callback = function(ev)
        local quarto = require("quarto")
        vim.keymap.set("n", "<localleader>qp", quarto.quartoPreview, { buffer = ev.buf, desc = "Quarto: preview" })
        vim.keymap.set("n", "<localleader>qc", quarto.quartoClosePreview, { buffer = ev.buf, desc = "Quarto: close preview" })
    end,
})

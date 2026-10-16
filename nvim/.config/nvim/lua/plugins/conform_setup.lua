require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bib = { "bibtex-tidy" },
        tex = { "tex-fmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
        python = { "ruff_organize_imports", "ruff_format" },
    },
    default_format_opts = {
        lsp_format = "fallback",
    },
    notify_on_error = true,
    format_on_save = function(_)
        if vim.g.autoformat then
            return { timeout_ms = 500, lsp_format = "fallback" }
        end
    end,
    formatters = {
        -- No wrapping: rewrapped paragraphs make noisy Overleaf diffs.
        ["tex-fmt"] = {
            prepend_args = { "--nowrap" },
        },
        ["latexindent"] = {
            command = "latexindent",
            args = { "-l", "-m" },
            range_args = function(_, ctx)
                return {
                    "--lines",
                    ctx.range.start[1] .. "-" .. ctx.range["end"][1],
                    "-",
                }
            end,
            stdin = true,
        },
    },
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
    require("conform").format({ async = true })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>uf", function()
    vim.g.autoformat = not vim.g.autoformat
end, { desc = "Toggle Format on Save" })

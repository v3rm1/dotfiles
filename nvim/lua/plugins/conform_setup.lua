require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bib = { "bibtex-tidy" },
        tex = { "latexindent" },
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

Snacks.toggle({
    id = "autoformat",
    name = "Format on save",
    get = function()
        return vim.g.autoformat
    end,
    set = function(_)
        vim.g.autoformat = not vim.g.autoformat
    end,
}):map("<leader>uf")

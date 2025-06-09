return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
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
            format_on_save = function(bufnr)
                if vim.g.autoformat then
                    return {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    }
                else
                    return
                end
            end,
        },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Format buffer",
            },
        },
        init = function()
            -- If you want the formatexpr, here is the place to set it
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
    {
        "snacks.nvim",
        opts = function()
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
        end,
    },
}

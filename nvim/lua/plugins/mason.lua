return {
    {
        -- mason LSP manager
        "mason-org/mason.nvim",
        opts = {},
    },
    {
        -- Easier mason config
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = require("lsp").list,
                automatic_enable = false,
            })
        end,
    },
    {
        -- mason tool utility
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        opts = {
            ensure_installed = {
                -- conform
                "stylua",
                "shfmt",
                "markdown-toc",
                "bibtex-tidy",
                "latexindent",

                -- nvim-lint
                "cmakelint",
                "markdownlint-cli2",

                -- dap
                "codelldb",
            },
        },
        config = function(_, opts)
            local mti = require("mason-tool-installer")
            mti.setup(opts)
        end,
    },
}

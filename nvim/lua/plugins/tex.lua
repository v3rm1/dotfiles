return {
    {
        "lervag/vimtex",
        lazy = false, -- Lazy-loading will disable inverse search
        config = function()
            vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- Disable `K` as it conflicts with LSP hover
            vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_quickfix_open_on_warning = 0
            -- vim.g.vimtex_view_method = "sioyek"
            vim.g.vimtex_view_method = "skim"


            vim.g.vimtex_compiler_latexmk = {
                aux_dir = './aux',
                out_dir = './build',
                callback = true,
                continuous = true,
                executable = 'latexmk',
                options = {
                    '-verbose',
                    '-file-line-error',
                    '-synctex=1',
                    '-interaction=nonstopmode',
                }
            }
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("my_nvim_latex_lsp_attach", { clear = true }),
                pattern = "*.tex",
                callback = function(event)
                    vim.keymap.set("n", "<leader>K", "<Plug>(vimtex-doc-package)", { desc = "Vimtex Docs", silent = true, buffer = event.buf })
                end,
            })
        end,
    },
}

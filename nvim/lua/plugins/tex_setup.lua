local texbin = "/Library/TeX/texbin"
if vim.fn.isdirectory(texbin) == 1 and not string.find(vim.env.PATH, texbin) then
    vim.env.PATH = texbin .. ":" .. vim.env.PATH
end

vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- Disable `K` as it conflicts with LSP hover
vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_view_method = vim.fn.has("mac") and "skim" or "zathura"
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1
vim.g.vimtex_format_enabled = true
vim.g.vimtex_syntax_conceal = {
    accents = 0,
    ligatures = 0,
    cites = 0,
    fancy = 0,
    spacing = 0,
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 1,
    math_super_sub = 1,
    math_symbols = 1,
    sections = 0,
    styles = 0,
}

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("my_latex_tools", { clear = true }),
    pattern = "tex",
    callback = function(event)
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, buffer = event.buf })
        end
        map("n", "<localleader>b", function() require("plugins.latex_tools").bib_pick() end,   "Bib Picker")
        map("n", "<localleader>p", function() require("plugins.latex_tools").eq_preview() end, "Equation Preview")
        map("x", "<localleader>p", function() require("plugins.latex_tools").eq_preview() end, "Equation Preview")
        map("n", "<localleader>w", function() require("plugins.latex_tools").word_count() end,  "Word Count")
        map("n", "<localleader>c", function()
            vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
            vim.notify("Conceal " .. (vim.wo.conceallevel == 0 and "off" or "on"))
        end, "Toggle Conceal")
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my_nvim_latex_lsp_attach", { clear = true }),
    pattern = "*.tex",
    callback = function(event)
        vim.keymap.set(
            "n",
            "<leader>K",
            "<Plug>(vimtex-doc-package)",
            { desc = "Vimtex Docs", silent = true, buffer = event.buf }
        )
    end,
})

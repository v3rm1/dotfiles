local fzf = require("fzf-lua")

fzf.setup({
    winopts = {
        border  = "single",
        preview = { border = "single" },
    },
})

local map = vim.keymap.set

map("n", "<leader><space>", fzf.files,       { desc = "Find Files (smart)" })
map("n", "<leader>/",       fzf.live_grep,                                                { desc = "Grep" })
map("n", "<leader>fb",      fzf.buffers,                                                  { desc = "Find Buffers" })
map("n", "<leader>fc",      function() fzf.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
map("n", "<leader>ff",      function() fzf.files({ hidden = true }) end,                  { desc = "Find Files" })
map("n", "<leader>fg",      fzf.git_files,                                                { desc = "Find Git Files" })
map("n", "<leader>fr",      fzf.oldfiles,                                                 { desc = "Find Recent Files" })

map({ "n", "x" }, "<leader>sw", fzf.grep_cword,                                          { desc = "Grep Word" })
map("n", "<leader>sa",      fzf.autocmds,                                                 { desc = "Autocmds" })
map("n", "<leader>sb",      fzf.blines,                                                   { desc = "Buffer Lines" })
map("n", "<leader>sc",      fzf.commands,                                                 { desc = "Commands" })
map("n", "<leader>sd",      fzf.diagnostics_workspace,                                    { desc = "Diagnostics" })
map("n", "<leader>sD",      fzf.diagnostics_document,                                     { desc = "Buffer Diagnostics" })
map("n", "<leader>sh",      fzf.help_tags,                                                { desc = "Help Pages" })
map("n", "<leader>sH",      fzf.highlights,                                               { desc = "Highlights" })
map("n", "<leader>sk",      fzf.keymaps,                                                  { desc = "Keymaps" })
map("n", "<leader>sm",      fzf.marks,                                                    { desc = "Marks" })
map("n", "<leader>sM",      fzf.man_pages,                                                { desc = "Man Pages" })
map("n", "<leader>sl",      fzf.loclist,                                                  { desc = "Location List" })
map("n", "<leader>sq",      fzf.quickfix,                                                 { desc = "Quickfix List" })
map("n", "<leader>ss",      fzf.lsp_document_symbols,                                     { desc = "LSP Symbols" })
map("n", "<leader>sS",      fzf.lsp_workspace_symbols,                                    { desc = "LSP Workspace Symbols" })
map("n", "<leader>s?",      function()
    local doc_dirs = vim.tbl_filter(
        function(p) return vim.fn.isdirectory(p) == 1 end,
        vim.tbl_map(function(p) return p .. "/doc" end, vim.opt.runtimepath:get())
    )
    fzf.live_grep({ search_paths = doc_dirs, prompt = "HelpGrep> " })
end, { desc = "Help Grep" })

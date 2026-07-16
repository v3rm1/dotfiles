local M = {}
local THRESHOLD = 1024 * 1024 -- 1MB

local group = vim.api.nvim_create_augroup("bigfile", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(args)
        local ok, stat = pcall(vim.uv.fs_stat, args.file)
        if ok and stat and stat.size > THRESHOLD then
            vim.b[args.buf].bigfile = true
            vim.opt_local.syntax = "off"
            vim.opt_local.swapfile = false
            vim.opt_local.spell = false
            vim.opt_local.undofile = false
        end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        if vim.b[args.buf].bigfile then
            vim.treesitter.stop(args.buf)
            vim.opt_local.foldmethod = "manual"
        end
    end,
})

return M

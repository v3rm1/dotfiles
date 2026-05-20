local M = {}

function M.open()
    if vim.g.lazygit_win and vim.api.nvim_win_is_valid(vim.g.lazygit_win) then
        vim.api.nvim_win_close(vim.g.lazygit_win, true)
        vim.g.lazygit_win = nil
        return
    end

    local width  = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.9)
    local col    = math.floor((vim.o.columns - width) / 2)
    local row    = math.floor((vim.o.lines - height) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative  = "editor",
        width     = width,
        height    = height,
        col       = col,
        row       = row,
        style     = "minimal",
        border    = "single",
        title     = " lazygit ",
        title_pos = "center",
    })
    vim.g.lazygit_win = win

    vim.fn.termopen("lazygit", {
        on_exit = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
            vim.g.lazygit_win = nil
        end,
    })
    vim.cmd("startinsert")
end

return M

local function augroup(name)
    return vim.api.nvim_create_augroup("my_nvim_" .. name, { clear = true })
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("highlight_on_yank"),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "startuptime",
        "fugitive",
        "nvim-undotree",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled" }, {
    group = augroup("scroll_past_eof"),
    callback = function(ev)
        local ignored_filetypes = { terminal = true }
        if ignored_filetypes[vim.bo.filetype] then
            return
        end

        -- Skip floating windows
        if vim.api.nvim_win_get_config(0).relative ~= "" then
            return
        end

        if ev.event == "WinScrolled" then
            local win_id = vim.api.nvim_get_current_win()
            local win_event = vim.v.event[tostring(win_id)]
            if win_event ~= nil and win_event.topline <= 0 then
                return
            end
        end

        local win = vim.api.nvim_get_current_win()
        local win_height = vim.api.nvim_win_get_height(win)
        local scrolloff = vim.o.scrolloff

        if win_height < scrolloff then
            return
        end

        -- Compute visual cursor line within the window
        local info = vim.fn.getwininfo(win)[1]
        local cursor_row = vim.api.nvim_win_get_cursor(win)[1]
        local win_cur_line = cursor_row - info.topline + 1
        local visual_distance_to_eof = win_height - win_cur_line

        if visual_distance_to_eof < scrolloff then
            local new_topline = info.topline + scrolloff - visual_distance_to_eof
            vim.fn.winrestview({ skipcol = 0, topline = new_topline })
        end
    end,
})

-- Antigravity CLI (agy) in a persistent right-hand terminal split, mirroring the
-- claudecode.nvim layout. agy has no IDE protocol, so context is sent as text:
-- selections are pasted (bracketed paste, so newlines don't submit) with their
-- file and line range; buffers are referenced by path for agy to read itself.
local M = {}

local state = { buf = nil, win = nil, job = nil }

local function alive()
    return state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.job
end

local function open_win()
    vim.cmd("botright vsplit")
    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(state.win, math.floor(vim.o.columns * 0.38))
    vim.wo[state.win].number = false
    vim.wo[state.win].signcolumn = "no"
    vim.wo[state.win].winbar = "%= agy "
end

local function start(args)
    open_win()
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.win, state.buf)
    local cmd = vim.list_extend({ "agy" }, args or {})
    state.job = vim.fn.jobstart(cmd, {
        term = true,
        cwd = vim.fn.getcwd(),
        on_exit = function()
            if state.win and vim.api.nvim_win_is_valid(state.win) then
                vim.api.nvim_win_close(state.win, true)
            end
            if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                vim.api.nvim_buf_delete(state.buf, { force = true })
            end
            state = { buf = nil, win = nil, job = nil }
        end,
    })
    vim.cmd("startinsert")
end

local function visible()
    return state.win and vim.api.nvim_win_is_valid(state.win)
end

-- Show the agy window (starting agy if needed) and optionally focus it.
local function show(focus)
    local prev = vim.api.nvim_get_current_win()
    if not alive() then
        start()
    elseif not visible() then
        open_win()
        vim.api.nvim_win_set_buf(state.win, state.buf)
    end
    if focus then
        vim.api.nvim_set_current_win(state.win)
        vim.cmd("startinsert")
    else
        vim.api.nvim_set_current_win(prev)
        vim.cmd("stopinsert")
    end
end

-- Toggle visibility; hiding keeps the session alive. Extra args (e.g. "-c")
-- only apply when a new session is started.
function M.toggle(args)
    if visible() then
        vim.api.nvim_win_close(state.win, true)
        state.win = nil
    elseif alive() then
        show(true)
    else
        start(args)
    end
end

function M.focus()
    show(true)
end

function M.send(text)
    show(true)
    vim.fn.chansend(state.job, "\27[200~" .. text .. "\27[201~")
end

function M.send_buffer()
    M.send(vim.fn.expand("%:.") .. " ")
end

-- Send the last visual selection with its location, followed by an optional prompt.
function M.send_selection(prompt)
    vim.cmd("normal! \27")
    local s, e = vim.fn.line("'<"), vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
    local text = string.format("%s:%d-%d\n```%s\n%s\n```\n", vim.fn.expand("%:."), s, e, vim.bo.filetype,
        table.concat(lines, "\n"))
    M.send(text .. (prompt or ""))
end

return M

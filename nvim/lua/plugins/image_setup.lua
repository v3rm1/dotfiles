local image_api = require("image")

image_api.setup({
    backend = "kitty",
    processor = "magick_cli",
    integrations = {},
    kitty_method = "normal",
    hijack_file_patterns = {},
})

local img_exts = { png = 1, jpg = 1, jpeg = 1, gif = 1, webp = 1, bmp = 1, tiff = 1, heic = 1, avif = 1, pdf = 1 }
local try_exts = { "png", "pdf", "jpg", "jpeg", "eps" }  -- LaTeX search order

local function resolve_path(raw)
    if not raw or raw == "" then return nil end
    local p = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if not p:match("^/") then
        p = vim.fn.expand("%:p:h") .. "/" .. p
    end
    p = vim.fn.fnamemodify(p, ":p")
    local ext = p:match("%.(%w+)$")
    if ext and img_exts[ext:lower()] and vim.fn.filereadable(p) == 1 then
        return p
    end
    -- no extension or unreadable: try appending common image extensions
    if not ext or vim.fn.filereadable(p) == 0 then
        local base = ext and p:gsub("%.[^.]+$", "") or p
        for _, e in ipairs(try_exts) do
            local candidate = base .. "." .. e
            if vim.fn.filereadable(candidate) == 1 then return candidate end
        end
    end
end

local function extract_path(line)
    -- LaTeX \includegraphics[opts]{path}
    local p = line:match("\\includegraphics%s*%b[]%s*{([^}]+)}")
           or line:match("\\includegraphics%s*{([^}]+)}")
    if p then return resolve_path(p) end
    -- markdown ![alt](path)
    p = line:match("!%[.-%]%((.-)%)")
    if p then return resolve_path(p) end
    -- file path under cursor
    return resolve_path(vim.fn.expand("<cfile>"))
end

local hover_state = { win = nil, buf = nil, img = nil }

local function close_hover()
    if hover_state.img then hover_state.img:clear() end
    if hover_state.win and vim.api.nvim_win_is_valid(hover_state.win) then
        vim.api.nvim_win_close(hover_state.win, true)
    end
    hover_state = { win = nil, buf = nil, img = nil }
end

local function open_hover_float(path)
    close_hover()

    local sw, sh = vim.o.columns, vim.o.lines
    local width  = math.floor(sw * 0.28)
    local height = math.floor(sh * 0.35)
    local col    = sw - width - 2   -- top-right, 2-col margin
    local row    = 1

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {  -- false = don't steal focus
        relative  = "editor",
        width     = width,
        height    = height,
        col       = col,
        row       = row,
        style     = "minimal",
        border    = "single",
        title     = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
        title_pos = "center",
        zindex    = 50,
    })

    local img = image_api.from_file(path, {
        window = win,
        buffer = buf,
        x = 0, y = 0,
        width = width,
        height = height,
    })

    if img then img:render() end
    hover_state = { win = win, buf = buf, img = img }

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
        buffer  = vim.api.nvim_get_current_buf(),
        once    = true,
        callback = close_hover,
    })
end

local function open_float(path)
    local sw, sh = vim.o.columns, vim.o.lines
    local width  = math.floor(sw * 0.6)
    local height = math.floor(sh * 0.6)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative  = "editor",
        width     = width,
        height    = height,
        col       = math.floor((sw - width) / 2),
        row       = math.floor((sh - height) / 2),
        style     = "minimal",
        border    = "single",
        title     = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
        title_pos = "center",
    })

    local img = image_api.from_file(path, {
        window = win,
        buffer = buf,
        x = 0, y = 0,
        width = width,
        height = height,
    })

    if img then img:render() end

    local function close()
        if img then img:clear() end
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q",     close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
    vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
end

local M = {}

-- Hover: show image at cursor in top-right float, auto-close on cursor move
function M.hover()
    local path = extract_path(vim.api.nvim_get_current_line())
    if path then
        open_hover_float(path)
    else
        close_hover()
    end
end

-- Open: centered float, stays until q/<Esc>
function M.open(path)
    path = vim.fn.expand(path)
    if vim.fn.filereadable(path) == 1 then
        open_float(path)
    else
        vim.notify("image_setup: not readable: " .. path, vim.log.levels.ERROR)
    end
end

vim.api.nvim_create_autocmd("CursorHold", {
    pattern = { "*.tex", "*.md" },
    callback = function() M.hover() end,
})

return M

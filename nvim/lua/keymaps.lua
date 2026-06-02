-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Window resizing
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer commands
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>",  { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>",      { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bl", "<cmd>buffer #<cr>",   { desc = "Last buffer" })
vim.keymap.set("n", "<leader>br", "<cmd>edit!<cr>",      { desc = "Reload buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<cr>",   { desc = "Force delete buffer" })
vim.keymap.set("n", "<leader>bo", function()
    local cur = vim.fn.bufnr()
    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if buf.bufnr ~= cur then
            pcall(vim.cmd, "bdelete " .. buf.bufnr)
        end
    end
end, { desc = "Close other buffers" })
vim.keymap.set("n", "<leader>bd", function()
    local alt = vim.fn.bufnr("#")
    if alt > 0 and vim.fn.buflisted(alt) == 1 then
        vim.cmd("buffer #")
    else
        vim.cmd("bprevious")
    end
    local cur = vim.fn.bufnr()
    if vim.fn.buflisted(cur) == 1 then vim.cmd("bdelete " .. cur) end
end, { desc = "Delete buffer (keep window)" })

-- Tab navigation
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Prev tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabNext<cr>", { desc = "Next tab" })

-- Better up/down on wrapped lines
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Better indenting (keep selection)
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Centered scrolling and search
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")


-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to void" })

-- Replace with yank operator
function _G.operator_replace_with_yank(type)
    if type == "line" then
        vim.cmd("normal! '[V']\"rdP")
    elseif type == "char" then
        vim.cmd('normal! `[v`]"rdP')
    else
        vim.notify("Block mode not supported.")
    end
end

vim.keymap.set(
    { "n", "o" },
    "<leader>p",
    "<cmd>set operatorfunc=v:lua.operator_replace_with_yank<CR>g@",
    { desc = "Replace with yank" }
)

-- Replace word in file
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace in file" })

-- Git autocommit
vim.keymap.set("n", "<leader>ga", function()
    local message = "autocommit: " .. os.date("%Y-%m-%dT%T%Z") .. "\n\n" .. vim.fn.system("git status --porcelain")
    vim.fn.system("git add .")
    vim.fn.system("git commit -m " .. vim.fn.shellescape(message))
end, { desc = "Git autocommit" })


vim.keymap.set("n", "gy", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
    vim.notify("Copied relative path")
end, { desc = "Copy relative path" })

vim.keymap.set("n", "gY", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
    vim.notify("Copied absolute path")
end, { desc = "Copy absolute path" })

-- Run file
local runners = {
    python     = "python3 %",
    rust       = "cargo run",
    javascript = "node %",
    typescript = "npx ts-node %",
    sh         = "bash %",
    zsh        = "zsh %",
    lua        = "lua %",
}
vim.keymap.set("n", "<leader>rr", function()
    local r = runners[vim.bo.filetype]
    if r then
        vim.cmd("split | terminal " .. r)
    else
        vim.notify("No runner for filetype: " .. vim.bo.filetype)
    end
end, { desc = "Run file" })

-- Close all floating windows
vim.keymap.set("n", "<leader>wc", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            pcall(vim.api.nvim_win_close, win, false)
        end
    end
end, { desc = "Close all floats" })

-- Toggle diagnostics
vim.keymap.set("n", "<leader>ud", function()
    local enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not enabled)
    vim.notify("Diagnostics " .. (enabled and "off" or "on"))
end, { desc = "Toggle Diagnostics" })

-- Pinned file slots (session-scoped)
local pins = {}
for i = 1, 4 do
    vim.keymap.set("n", "<leader>m" .. i, function()
        pins[i] = vim.fn.expand("%:p")
        vim.notify("Pinned slot " .. i .. ": " .. vim.fn.expand("%:."))
    end, { desc = "Pin file to slot " .. i })
    vim.keymap.set("n", "<leader>" .. i, function()
        if pins[i] and vim.fn.filereadable(pins[i]) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(pins[i]))
        else
            vim.notify("Slot " .. i .. " empty")
        end
    end, { desc = "Jump to pinned slot " .. i })
end

-- Undotree
vim.keymap.set("n", "<leader>uu", function()
    require("undotree").open({ command = "botright 35vnew" })
end, { desc = "Toggle Undotree" })

-- URL opener
vim.keymap.set("n", "gx", function()
    local url = vim.fn.expand("<cfile>")
    if url:match("^https?://") then
        vim.fn.jobstart({ "open", url })
    else
        vim.notify("Not a URL: " .. url)
    end
end, { desc = "Open URL" })

-- Project search → quickfix (then use :cdo s/old/new/g)
vim.keymap.set("n", "<leader>sr", function()
    local word = vim.fn.input("Search: ")
    if word ~= "" then
        require("fzf-lua").grep({ search = word })
    end
end, { desc = "Search project (→ quickfix)" })

-- Notification history
local _notif_history = {}
local _orig_notify = vim.notify
vim.notify = function(msg, level, opts)
    table.insert(_notif_history, { msg = tostring(msg), time = os.date("%H:%M:%S"), level = level })
    _orig_notify(msg, level, opts)
end
vim.keymap.set("n", "<leader>nh", function()
    if #_notif_history == 0 then
        vim.notify("No notifications yet")
        return
    end
    local lines = vim.tbl_map(function(e) return e.time .. "  " .. e.msg end, _notif_history)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, buf)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
end, { desc = "Notification history" })

-- Zen mode
local _zen_active = false
vim.keymap.set("n", "<leader>uz", function()
    if not _zen_active then
        vim.o.laststatus  = 0
        vim.o.showtabline = 0
        vim.o.winbar      = ""
        vim.cmd("wincmd | vertical resize 88")
        _zen_active = true
    else
        vim.o.laststatus  = 3
        vim.o.showtabline = 1
        vim.o.winbar      = "%=%m %f"
        vim.cmd("wincmd =")
        _zen_active = false
    end
end, { desc = "Toggle Zen mode" })

-- Norwegian keyboard layout
vim.keymap.set({ "n", "o", "v", "x" }, "ø", "[", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "æ", "]", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "Ø", "{", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "Æ", "}", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "-", "/", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "[ø", "[[", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "]æ", "]]", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "gø", "g[", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "gæ", "g]", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "gØ", "g{", { remap = true })
vim.keymap.set({ "n", "o", "v", "x" }, "gÆ", "g}", { remap = true })

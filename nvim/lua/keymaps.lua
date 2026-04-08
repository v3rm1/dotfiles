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

-- Buffer navigation
vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "d<tab>", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

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

-- Alternate file
vim.keymap.set("n", "<localleader>b", "<C-^>", { desc = "Alternate file" })

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

vim.keymap.set("n", "<leader>uu", ":Undotree<CR>", { desc = "Toggle UndoTree" })

vim.keymap.set("n", "gy", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
    vim.notify("Copied relative path")
end, { desc = "Copy relative path" })

vim.keymap.set("n", "gY", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
    vim.notify("Copied absolute path")
end, { desc = "Copy absolute path" })

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

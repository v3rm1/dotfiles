-- claudecode.nvim: Claude Code IDE integration (same protocol as the VS Code /ide
-- extension). Claude sees the current file, selection and diagnostics, and proposes
-- edits as diffs to accept/deny here. Hiding the terminal keeps the session alive.
require("claudecode").setup({
    track_selection = true,
    focus_after_send = true,
    terminal = {
        provider = "native",
        split_side = "right",
        split_width_percentage = 0.38,
        diff_split_width_percentage = 0.25,
    },
    diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
    },
})

local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Claude: toggle")
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Claude: focus")
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Claude: resume session")
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", "Claude: continue last session")
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", "Claude: select model")
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Claude: add buffer")
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Claude: send selection")
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Claude: accept diff")
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Claude: deny diff")

-- Pair-programming prompts: send the selection, then a request, in one keystroke.
-- Leave visual mode first so '< and '> are set; the short delay lets the
-- @-mention land in Claude's prompt before the request text is typed after it.
local function send_selection_with(prompt)
    return function()
        vim.cmd("normal! \27")
        vim.cmd("'<,'>ClaudeCodeSend")
        vim.defer_fn(function()
            require("claudecode.terminal").send_to_terminal(prompt)
        end, 200)
    end
end

map("v", "<leader>at", send_selection_with("Write tests for the selected code, run them, and report failures."), "Claude: test selection")
map("v", "<leader>ax", send_selection_with("Review the selected code for bugs and edge cases. Reproduce before claiming."), "Claude: check selection")
map("n", "<leader>ak", "<cmd>ClaudeCodeSendText check<cr>", "Claude: check my latest changes")

-- oil.nvim: add the file under the cursor to Claude's context
vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function(ev)
        vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Claude: add file" })
    end,
})

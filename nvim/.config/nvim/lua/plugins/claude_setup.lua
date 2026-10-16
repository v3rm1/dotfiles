-- claudecode.nvim: Claude Code IDE integration (same protocol as the VS Code /ide
-- extension). Claude sees the current file, selection and diagnostics, and proposes
-- edits as diffs to accept/deny here. Hiding the terminal keeps the session alive.
require("lazyload").add({
    plugins = { "claudecode.nvim" },
    modules = { "claudecode" },
    cmd = {
        "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd", "ClaudeCodeSend",
        "ClaudeCodeSendText", "ClaudeCodeTreeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
        "ClaudeCodeStart", "ClaudeCodeStop", "ClaudeCodeStatus", "ClaudeCodeOpen", "ClaudeCodeClose",
    },
    setup = function()
        require("claudecode").setup({
            -- Claude's own vim input mode fights nvim's; use plain input here only.
            -- nvim's terminal leaks Ghostty's OSC 777 notifications into the
            -- prompt as text, so notify with the bell, which nvim passes on.
            terminal_cmd = [[claude --settings '{"editorMode":"normal","preferredNotifChannel":"terminal_bell"}']],
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
    end,
})

local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Claude keeps transcripts in ~/.claude/projects/<cwd with non-alphanumerics as "-">.
-- Continue the last one if this project has any; `claude -c` errors out otherwise.
local function has_saved_session()
    local dir = vim.fs.normalize("~/.claude/projects") .. "/" .. vim.fn.getcwd():gsub("[^%w]", "-")
    return vim.fn.glob(dir .. "/*.jsonl") ~= ""
end

map("n", "<leader>ac", function()
    vim.cmd(has_saved_session() and "ClaudeCode --continue" or "ClaudeCode")
end, "Claude: toggle (continue last session)")
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Claude: focus")
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Claude: resume session")
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

-- Prose (markdown/LaTeX): the same <leader>a keys drive agy instead of Claude.
-- Buffer-local maps shadow the global Claude ones; code buffers keep Claude.
-- Neovim has no filetype for .mdx, so register one for the autocmd to match.
vim.filetype.add({ extension = { mdx = "mdx" } })
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("my_agy_prose", { clear = true }),
    pattern = { "markdown", "quarto", "rmd", "mdx", "pandoc", "livebook", "tex", "plaintex", "bib" },
    callback = function(ev)
        local agy = require("native.agy")
        local bmap = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end
        bmap("n", "<leader>ac", function() agy.toggle() end, "agy: toggle")
        bmap("n", "<leader>af", agy.focus, "agy: focus")
        bmap("n", "<leader>ab", agy.send_buffer, "agy: add buffer")
        bmap("v", "<leader>as", function() agy.send_selection() end, "agy: send selection")
        bmap("v", "<leader>ax", function()
            agy.send_selection("Proofread the selection: grammar, clarity, British spelling. Propose edits, don't apply.")
        end, "agy: proofread selection")
    end,
})

-- oil.nvim: add the file under the cursor to Claude's context
vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function(ev)
        vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Claude: add file" })
    end,
})

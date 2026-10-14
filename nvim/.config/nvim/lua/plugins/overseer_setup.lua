-- overseer: task runner with templates detected from cargo, make, just, npm,
-- VS Code tasks.json etc. Task output lives in its own buffer and list.
require("lazyload").add({
    plugins = { "overseer.nvim" },
    modules = { "overseer" },
    cmd = { "OverseerToggle", "OverseerOpen", "OverseerClose", "OverseerRun", "OverseerShell", "OverseerTaskAction" },
    setup = function()
        -- dap integration enabled only if nvim-dap is already loaded (and by
        -- dap_setup otherwise), so overseer doesn't pull dap in
        require("overseer").setup({ dap = false })
        if package.loaded.dap then
            require("overseer").enable_dap(true)
        end
    end,
})

local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = "Overseer: " .. desc })
end

map("<leader>oo", "<cmd>OverseerToggle!<cr>", "toggle task list")
map("<leader>or", "<cmd>OverseerRun<cr>", "run task")
map("<leader>os", ":OverseerShell ", "run shell command")
map("<leader>oa", "<cmd>OverseerTaskAction<cr>", "task action")

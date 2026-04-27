local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Auto open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- Python setup
require("dap-python").setup("python3") -- Uses the python in your path or venv

-- C / C++ / Rust setup (codelldb)
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
    },
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceRoot}",
        stopOnEntry = false,
    },
}

dap.configurations.c = dap.configurations.cpp

-- Keymaps
local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { desc = "Debug: " .. desc })
end

map("<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
map("<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "Breakpoint Condition")
map("<leader>dc", dap.continue, "Continue (Start)")
map("<leader>di", dap.step_into, "Step Into")
map("<leader>do", dap.step_over, "Step Over")
map("<leader>dt", dap.step_out, "Step Out")
map("<leader>dr", dap.repl.open, "Open REPL")
map("<leader>dl", dap.run_last, "Run Last")
map("<leader>du", dapui.toggle, "Toggle UI")
map("<leader>dx", dap.terminate, "Terminate")

-- nvim-dap loads on the first debug keymap or require("dap") (e.g. rustaceanvim).
require("lazyload").add({
    plugins = { "nvim-nio", "nvim-dap", "nvim-dap-ui", "nvim-dap-python" },
    modules = { "dap", "dapui", "dap-python" },
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapNew", "DapTerminate" },
    setup = function()
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

        -- Python setup: resolve pixi env lazily per session
        local function resolve_python()
            local pixi = vim.fn.getcwd() .. "/.pixi/envs/default/bin/python"
            return vim.fn.filereadable(pixi) == 1 and pixi or "python3"
        end

        require("dap-python").setup("python3")

        for _, config in ipairs(dap.configurations.python or {}) do
            config.pythonPath = resolve_python
        end

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

        -- overseer: preLaunchTask/postDebugTask support
        if package.loaded.overseer then
            require("overseer").enable_dap(true)
        end
    end,
})

local function dap(fn)
    return function()
        return fn(require("dap"))
    end
end

-- Keymaps
local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { desc = "Debug: " .. desc })
end

map("<leader>db", dap(function(d) d.toggle_breakpoint() end), "Toggle Breakpoint")
map("<leader>dB", dap(function(d)
    d.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end), "Breakpoint Condition")
map("<leader>dc", dap(function(d) d.continue() end), "Continue (Start)")
map("<leader>di", dap(function(d) d.step_into() end), "Step Into")
map("<leader>do", dap(function(d) d.step_over() end), "Step Over")
map("<leader>dt", dap(function(d) d.step_out() end), "Step Out")
map("<leader>dr", dap(function(d) d.repl.open() end), "Open REPL")
map("<leader>dl", dap(function(d) d.run_last() end), "Run Last")
map("<leader>du", function() require("dapui").toggle() end, "Toggle UI")
map("<leader>dx", dap(function(d) d.terminate() end), "Terminate")

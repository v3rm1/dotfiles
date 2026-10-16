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

        -- Pick a built binary from the usual output dirs (cargo, CMake, make),
        -- falling back to typing a path when none are found. Files with an
        -- extension (scripts, libraries) are skipped.
        local function pick_program()
            local cwd = vim.fn.getcwd()
            local candidates = {}
            for _, pattern in ipairs({ "target/debug/*", "build/*", "build/**/bin/*", "cmake-build-*/*", "*" }) do
                for _, path in ipairs(vim.fn.glob(cwd .. "/" .. pattern, false, true)) do
                    local name = vim.fs.basename(path)
                    if not name:find("%.") and vim.fn.isdirectory(path) == 0 and vim.fn.executable(path) == 1 then
                        candidates[#candidates + 1] = vim.fn.fnamemodify(path, ":.")
                    end
                end
            end
            if #candidates == 0 then
                local path = vim.fn.input("Path to executable: ", cwd .. "/", "file")
                return path ~= "" and path or dap.ABORT
            end
            local co = coroutine.running()
            vim.ui.select(candidates, { prompt = "Executable" }, function(choice)
                coroutine.resume(co, choice or dap.ABORT)
            end)
            return coroutine.yield()
        end

        -- Attach to QEMU's gdbstub (run QEMU with -s, plus -S to wait for the
        -- debugger, e.g. QEMU_EXTRA="-s -S"); symbols come from an ELF such as
        -- the kernel's vmlinux (looked for in the usual Buildroot/kernel spots).
        -- Called (via __call) when the config is chosen, so prompts run per session.
        local qemu_attach = setmetatable({ name = "Attach to QEMU gdbstub" }, {
            __call = function(self)
                local found
                for _, pattern in ipairs({
                    "vmlinux",
                    "*/vmlinux",
                    "*/build/linux-*/vmlinux",
                    "*/output/build/linux-*/vmlinux",
                }) do
                    found = found or vim.fn.glob(vim.fn.getcwd() .. "/" .. pattern, false, true)[1]
                end
                local elf = vim.fn.input("Symbol file (ELF): ", found or vim.fn.getcwd() .. "/", "file")
                local port = vim.fn.input("gdbstub port: ", "1234")
                return {
                    name = self.name,
                    type = "codelldb",
                    request = "launch",
                    custom = true,
                    targetCreateCommands = elf ~= "" and { "target create " .. vim.fn.fnameescape(elf) } or dap.ABORT,
                    processCreateCommands = { "gdb-remote localhost:" .. port },
                }
            end,
        })

        local function native_configs()
            return {
                {
                    name = "Launch executable",
                    type = "codelldb",
                    request = "launch",
                    program = pick_program,
                    args = function()
                        return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
                {
                    name = "Attach to process",
                    type = "codelldb",
                    request = "attach",
                    pid = function()
                        return require("dap.utils").pick_process()
                    end,
                },
                qemu_attach,
            }
        end

        dap.configurations.cpp = native_configs()
        dap.configurations.c = dap.configurations.cpp
        -- Separate list: rustaceanvim appends its cargo targets to this one.
        dap.configurations.rust = native_configs()

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

-- Minimal lazy loader for vim.pack. Plugins registered with
-- `vim.pack.add(specs, { load = function() end })` are installed but not on
-- 'runtimepath'; a spec here says what loads them:
--   plugins  pack names to :packadd (dependencies first)
--   modules  top-level Lua module names: the first require() loads the spec
--   cmd      user commands: stubs that load the spec then re-run the command
--   ft       filetypes: load on FileType, then re-fire it for the buffer so
--            the plugin's ftplugin and FileType autocmds see it
--   event    autocmd events (once)
--   defer    true: load right after startup (after the first screen)
--   setup    function or module name run once after :packadd
local M = {}

local by_module = {}

local function source_after(name)
    for _, dir in ipairs(vim.api.nvim_get_runtime_file("pack/*/opt/" .. name, false)) do
        for _, f in ipairs(vim.fn.glob(dir .. "/after/plugin/**/*.{vim,lua}", false, true)) do
            vim.cmd.source({ f, magic = { file = false } })
        end
    end
end

function M.load(spec)
    if spec.loaded then
        return
    end
    spec.loaded = true
    for _, name in ipairs(spec.plugins or {}) do
        vim.cmd.packadd({ name, magic = { file = false } })
        -- :packadd sources after/plugin only during startup
        if vim.v.vim_did_enter == 1 then
            source_after(name)
        end
    end
    if type(spec.setup) == "string" then
        require(spec.setup)
    elseif spec.setup then
        spec.setup()
    end
end

-- require() hook: load the owning spec, then hand back the module without
-- loading it twice (setup may already have required it).
local function hook(modname)
    local spec = by_module[modname:match("^[^.]+")]
    if not spec or spec.loaded then
        return nil
    end
    M.load(spec)
    -- capture now: require() swaps in a sentinel before calling the loader
    local mod = package.loaded[modname]
    if mod ~= nil then
        return function()
            return mod
        end
    end
    for _, loader in ipairs(package.loaders) do
        if loader ~= hook then
            local found = loader(modname)
            if type(found) == "function" then
                return found
            end
        end
    end
    return nil
end
table.insert(package.loaders, 2, hook)

local function cmd_stub(spec, name)
    vim.api.nvim_create_user_command(name, function(o)
        pcall(vim.api.nvim_del_user_command, name)
        M.load(spec)
        local range = o.range == 2 and (o.line1 .. "," .. o.line2) or (o.range == 1 and tostring(o.line1) or "")
        vim.cmd(range .. name .. (o.bang and "!" or "") .. " " .. o.args)
    end, { nargs = "*", bang = true, range = true })
end

function M.add(spec)
    for _, mod in ipairs(spec.modules or {}) do
        by_module[mod] = spec
    end
    for _, name in ipairs(spec.cmd or {}) do
        cmd_stub(spec, name)
    end
    if spec.ft then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = spec.ft,
            once = true,
            callback = function(ev)
                if spec.loaded then
                    return
                end
                M.load(spec)
                vim.api.nvim_buf_call(ev.buf, function()
                    vim.cmd.doautocmd({ "FileType", ev.match })
                end)
            end,
        })
    end
    if spec.event then
        vim.api.nvim_create_autocmd(spec.event, {
            once = true,
            callback = function()
                M.load(spec)
            end,
        })
    end
    if spec.defer then
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                vim.schedule(function()
                    M.load(spec)
                end)
            end,
        })
    end
    return spec
end

return M

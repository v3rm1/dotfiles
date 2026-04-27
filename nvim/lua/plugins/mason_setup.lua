local function install_missing(tools)
    local registry = require("mason-registry")
    local to_install = {}
    for _, name in ipairs(tools) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
            table.insert(to_install, pkg)
        end
    end

    if #to_install == 0 then
        return
    end

    local total = #to_install
    local finished = 0
    local progress = {
        kind = "progress",
        source = "mason",
        title = "mason",
    }

    for _, pkg in ipairs(to_install) do
        progress.status = "running"
        progress.id =
            vim.api.nvim_echo({ { ("Installing %s (%d/%d)"):format(pkg.name, finished, total) } }, false, progress)
        pkg:install():once(
            "closed",
            vim.schedule_wrap(function()
                finished = finished + 1
                local is_done = finished == total
                progress.status = is_done and "success" or "running"
                progress.id = vim.api.nvim_echo({
                    {
                        ("Installed %s (%d/%d)"):format(pkg.name, finished, total),
                    },
                }, is_done, progress)
            end)
        )
    end
end

local name_to_mason = {
    lua_ls = "lua-language-server",
}

local function tool_list()
    local tools = {
        "stylua",
        "shfmt",
        "bibtex-tidy",
        "latexindent",
        "debugpy",
        "codelldb",
    }
    for name, _ in pairs(require("lsp_setup").servers) do
        table.insert(tools, name_to_mason[name] or name)
    end
    return tools
end

require("mason").setup()
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local tools = tool_list()
        install_missing(tools)
    end,
})

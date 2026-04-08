local oil = require("oil")
oil.setup({
    default_file_explorer = true,
    columns = { "size", "mtime", "type", "permissions", "icon" },
    delete_to_trash = true,
    watch_for_changes = true,
    constrain_cursor = false,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ["<C-r>"] = "actions.refresh",
        ["gt"] = "actions.toggle_trash",
        ["q"] = "actions.close",
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = false,
        ["<C-l>"] = false,
    },
    lsp_file_methods = { enabled = false },
    float = { border = "rounded" },
    confirmation = { border = "rounded" },
    progress = { border = "rounded" },
    ssh = { border = "rounded" },
    keymaps_help = { border = "rounded" },
})

local function open_oil(path)
    if path == "local" then
        oil.open("oil://")
    else
        oil.open("oil-ssh://" .. path .. "/")
    end
end

vim.api.nvim_create_user_command("Ofs", function(opts)
    local host = opts.args
    if host == "" then
        local choices = get_ssh_hosts()
        table.insert(choices, 1, "local")
        vim.ui.select(choices, { prompt = "Select: " }, function(selected)
            if selected then
                open_oil(selected)
            end
        end)
    else
        open_oil(host)
    end
end, { nargs = "?" })

vim.keymap.set("n", "<leader>e", oil.open_float, { desc = "Oil File Explorer" })
vim.keymap.set("n", "<leader>E", ":Ofs<CR>", { desc = "Oil SSH" })

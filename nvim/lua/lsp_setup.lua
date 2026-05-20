local M = {}

-- LSP server configurations
M.servers = {
    -- lua
    lua_ls = {
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                completion = { callSnippet = "Replace" },
                workspace = { checkThirdParty = false },
                format = { enable = false },
            },
        },
    },

    -- tex
    texlab = {
        settings = {
            texlab = {
                inlayHints = {
                    maxLength = 12,
                },
                latexindent = {
                    ["local"] = "localSettings.yaml",
                    modifyLineBreaks = true,
                },
            },
        },
    },

    -- python
    ruff = {},
    pyrefly = {},
    ty = {},

    -- c, cpp
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
        },
        init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
        },
    },

    -- zig
    zls = {},
}

function M.setup()
    for name, config in pairs(M.servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
    end

    vim.diagnostic.config({
        float = {
            border = "rounded",
        },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my_nvim_lsp_attach", { clear = true }),
        callback = function(event)
            local fzf = require("fzf-lua")
            local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
            local bufnr = event.buf
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
            end
            map("gll", fzf.lsp_finder,          "All (picker)")
            map("gld", fzf.lsp_definitions,    "Definitions")
            map("glD", fzf.lsp_declarations,    "Declarations")
            map("glr", fzf.lsp_references,      "References")
            map("gli", fzf.lsp_implementations, "Implementations")
            map("glt", fzf.lsp_typedefs,        "Type Definitions")
            if client.name == "clangd" then
                map("<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header")
            end
            map("K", function()
                vim.lsp.buf.hover({ border = "single" })
            end, "Hover")
            map("gF", vim.lsp.buf.format, "Format")
            map("]e", function()
                vim.diagnostic.jump({
                    count = 1,
                    severity = vim.diagnostic.severity.ERROR,
                })
            end, "Next [e]rror")
            map("[e", function()
                vim.diagnostic.jump({
                    count = -1,
                    severity = vim.diagnostic.severity.ERROR,
                })
            end, "Previous [e]rror")
            map("<leader>cd", vim.diagnostic.open_float, "Show diagnostics")
        end,
    })
end

return M

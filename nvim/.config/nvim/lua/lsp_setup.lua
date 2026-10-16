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

    -- prose: grammar checking (British spelling) and markdown links/headings
    harper_ls = {
        filetypes = { "markdown", "tex", "gitcommit", "typst" },
        settings = {
            ["harper-ls"] = {
                dialect = "British",
            },
        },
    },
    marksman = {},

    -- python
    ruff = {},
    -- ty finds .venv itself but not pixi envs (conda layout); point CONDA_PREFIX at the
    -- project's default pixi env when there is one.
    ty = {
        cmd = function(dispatchers, config)
            local env = {}
            local pixi = config.root_dir and config.root_dir .. "/.pixi/envs/default"
            if pixi and vim.uv.fs_stat(pixi) then
                env.CONDA_PREFIX = pixi
            end
            return vim.lsp.rpc.start({ "ty", "server" }, dispatchers, { cwd = config.root_dir, env = env })
        end,
    },

    -- c, cpp
    clangd = {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
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

    -- build, config and system files
    bashls = {},
    neocmake = {},
    taplo = {},
    yamlls = {},
    jsonls = {},
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
            -- resolve on call so attaching a client doesn't load fzf-lua
            local fzf = setmetatable({}, {
                __index = function(_, k)
                    return function(...)
                        return require("fzf-lua")[k](...)
                    end
                end,
            })
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

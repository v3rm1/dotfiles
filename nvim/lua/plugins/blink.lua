return {
    {
        "saghen/blink.cmp",
        event = { "InsertEnter" },
        version = "1.*",
        dependencies = {
            -- "giuxtaposition/blink-cmp-copilot",
            {
                "folke/lazydev.nvim",
                ft = "lua",
                cmd = "LazyDev",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                        { path = "snacks.nvim", words = { "Snacks" } },
                        { path = "lazy.nvim", words = { "LazyVim" } },
                    },
                },
            },
            {
                "L3MON4D3/LuaSnip",
                version = "2.*",
                build = "make install_jsregexp",
                dependencies = {
                    {
                        "rafamadriz/friendly-snippets",
                        config = function()
                            require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
                            require("luasnip.loaders.from_vscode").lazy_load({
                                paths = { vim.fn.stdpath("config") .. "/snippets" },
                            })
                            require("luasnip.loaders.from_vscode").lazy_load()
                            vim.keymap.set("n", "<leader>sl", require("luasnip.loaders").edit_snippet_files, { desc = "Luasnip edit snippet" })
                        end,
                    },
                },
            },
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = "default",

                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-y>"] = { "accept" },
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.snippet_active() then
                            return cmp.accept()
                        else
                            return cmp.select_and_accept()
                        end
                    end,
                    "snippet_forward",
                    "fallback",
                },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },

                ["<Up>"] = {},
                ["<Down>"] = {},
                ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
                ["<C-n>"] = { "select_next", "fallback_to_mappings" },

                ["<C-Up>"] = { "scroll_documentation_up", "fallback" },
                ["<C-Down>"] = { "scroll_documentation_down", "fallback" },

                ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
            },

            snippets = { preset = "luasnip" },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            completion = {
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
                documentation = {
                    auto_show = false,
                    window = {
                        border = "rounded",
                    },
                },
                menu = {
                    draw = {
                        treesitter = { "lsp" },
                        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
                        align_to = "kind_icon",
                    },
                },
            },
            signature = {
                enabled = true,
                window = {
                    border = "rounded",
                    show_documentation = false,
                    treesitter_highlighting = true,
                },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer", "lazydev" },
                providers = {
                    path = {
                        opts = {
                            show_hidden_files_by_default = true,
                            get_cwd = function(ctx)
                                return vim.fn.getcwd()
                            end,
                        },
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100, -- show at a higher priority than lsp
                    },

                    -- copilot = {
                    --     name = "copilot",
                    --     module = "blink-cmp-copilot",
                    --     score_offset = 100,
                    --     async = true,
                    -- },
                },
            },
            cmdline = {
                enabled = false,
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },
        opts_extend = { "sources.default" },
    },
}

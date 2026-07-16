require("blink.cmp").setup({
    keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-y>"] = { "accept" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<M-n>"] = { "snippet_forward", "fallback" },
        ["<M-p>"] = { "snippet_backward", "fallback" },
        ["<Up>"] = {},
        ["<Down>"] = {},
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-Up>"] = { "scroll_documentation_up", "fallback" },
        ["<C-Down>"] = { "scroll_documentation_down", "fallback" },
        ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },

    completion = {
        list = {
            selection = { preselect = true, auto_insert = true },
        },
        documentation = {
            auto_show = true,
            window = { border = "rounded" },
        },
        menu = {
            draw = {
                treesitter = { "lsp" },
                columns = {
                    { "kind_icon" },
                    { "label", "label_description", gap = 1 },
                    { "source_name" },
                },
                align_to = "kind_icon",
            },
        },
    },

    signature = {
        enabled = true,
        window = {
            border = "single",
            scrollbar = true,
            show_documentation = true,
            treesitter_highlighting = true,
        },
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
            path = {
                opts = {
                    show_hidden_files_by_default = true,
                    get_cwd = function(_)
                        return vim.fn.getcwd()
                    end,
                },
            },
            lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100,
            },
        },
    },

    cmdline = {
        enabled = true,
        completion = {
            menu = { auto_show = true },
            list = {
                selection = { preselect = false, auto_insert = true },
            },
        },
    },
})

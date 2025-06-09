return {
    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        event = "VeryLazy",
        config = function()
            local ai = require("mini.ai")
            local extra = require("mini.extra")
            ai.setup({
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                    i = extra.gen_ai_spec.indent(),
                    g = extra.gen_ai_spec.buffer(),
                    d = extra.gen_ai_spec.number(),
                    u = ai.gen_spec.function_call(),
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
                },
            })

            local hipattern = require("mini.hipatterns")
            hipattern.setup({
                highlighters = {
                    -- Highlight hex color strings (`#rrggbb`) using that color
                    hex_color = hipattern.gen_highlighter.hex_color({ priority = 2000 }),
                    shorthand = {
                        pattern = "()#%x%x%x()%f[^%x%w]",
                        group = function(_, _, data)
                            ---@type string
                            local match = data.full_match
                            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                            local hex_color = "#" .. r .. r .. g .. g .. b .. b

                            return hipattern.compute_hex_color_group(hex_color, "bg")
                        end,
                        extmark_opts = { priority = 2000 },
                    },
                },
            })

            require("mini.surround").setup({
                mappings = {
                    add = "gsa", -- Add surrounding in Normal and Visual modes
                    delete = "gsd", -- Delete surrounding
                    find = "gsf", -- Find surrounding (to the right)
                    find_left = "gsF", -- Find surrounding (to the left)
                    highlight = "gsh", -- Highlight surrounding
                    replace = "gsr", -- Replace surrounding
                    update_n_lines = "gsn", -- Update `n_lines`
                },
            })

            require("mini.jump").setup({
                delay = {
                    idle_stop = 10000,
                },
            })

            -- local MiniStatusline = require("mini.statusline")
            -- MiniStatusline.setup({})
            -- require("mini.tabline").setup()
            require("mini.move").setup()
            require("mini.splitjoin").setup() -- gS
            require("mini.misc").setup() -- printing table and stuff
            require("mini.pairs").setup()
            require("mini.icons").setup()
            require("mini.icons").mock_nvim_web_devicons()

            Snacks.toggle
                .new({
                    id = "minipairs",
                    name = "Mini.Pairs",
                    get = function()
                        return not vim.g.minipairs_disable
                    end,
                    set = function(_)
                        vim.g.minipairs_disable = not vim.g.minipairs_disable
                    end,
                })
                :map("<leader>up")
        end,
    },
}

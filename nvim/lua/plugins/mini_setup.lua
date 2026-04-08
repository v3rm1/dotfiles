local ai = require("mini.ai")
local extra = require("mini.extra")
ai.setup({
    custom_textobjects = {
        o = ai.gen_spec.treesitter({
            a = {
                "@block.outer",
                "@conditional.outer",
                "@loop.outer",
                "@code_cell.outer",
            },
            i = {
                "@block.inner",
                "@conditional.inner",
                "@loop.inner",
                "@code_cell.inner",
            },
        }),
        f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
        }),
        c = ai.gen_spec.treesitter({
            a = { "@class.outer" },
            i = { "@class.inner" },
        }),
        i = extra.gen_ai_spec.indent(),
        g = extra.gen_ai_spec.buffer(),
        d = extra.gen_ai_spec.number(),
        L = extra.gen_ai_spec.line(),
        D = extra.gen_ai_spec.diagnostic(),
        j = require("utils").ts_textobj_delimiter_miniai({
            a = { "@jps" },
            i = { "@jps" },
        }),
        u = ai.gen_spec.function_call(),
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
    },
    n_lines = 500,
})

require("mini.surround").setup({
    mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
    },
})

require("mini.jump").setup({
    mappings = {
        repeat_jump = "",
    },
    delay = {
        idle_stop = 10000,
    },
})

require("mini.move").setup()
require("mini.splitjoin").setup()
require("mini.misc").setup()
require("mini.pairs").setup({
    mappings = {
        ["`"] = false,
    },
})
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
require("mini.comment").setup()

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

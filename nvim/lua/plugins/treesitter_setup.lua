vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter.setup", {}),
    callback = function(args)
        local buf = args.buf
        local ft = args.match
        local language = vim.treesitter.language.get_lang(ft) or ft
        local ts = require("nvim-treesitter")
        if not vim.tbl_contains(ts.get_installed(), language) and vim.tbl_contains(ts.get_available(), language) then
            ts.install(language)
        end
        if not vim.treesitter.language.add(language) then
            return
        end
        vim.treesitter.start(buf, language)
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

local tsc = require("treesitter-context")
tsc.setup({
    mode = "cursor",
    max_lines = 4,
})
Snacks.toggle({
    name = "Treesitter Context",
    get = tsc.enabled,
    set = function(state)
        if state then
            tsc.enable()
        else
            tsc.disable()
        end
    end,
}):map("<leader>ut")

local function move_mappings(key, query, desc_name)
    vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
        require("nvim-treesitter-textobjects.move").goto_previous_start(query, "textobjects")
    end, { desc = "Goto: prev " .. desc_name })
    vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
        require("nvim-treesitter-textobjects.move").goto_next_start(query, "textobjects")
    end, { desc = "Goto: next " .. desc_name })
    vim.keymap.set({ "n", "x", "o" }, "[" .. key:upper(), function()
        require("nvim-treesitter-textobjects.move").goto_previous_end(query, "textobjects")
    end, { desc = "Goto: prev " .. desc_name .. " end" })
    vim.keymap.set({ "n", "x", "o" }, "]" .. key:upper(), function()
        require("nvim-treesitter-textobjects.move").goto_next_end(query, "textobjects")
    end, { desc = "Goto: next " .. desc_name .. " end" })
end

move_mappings("f", "@function.outer", "function")
move_mappings("a", "@parameter.outer", "argument")
move_mappings("c", "@class.outer", "class")
move_mappings("o", "@code_cell.inner", "code cell")
move_mappings("j", "@jps", "jps")

local langs = {
	"bash",
	"bibtex",
	"c",
	"cpp",
	"cmake",
	"diff",
	"dockerfile",
	"git_config",
	"gitcommit",
	"git_rebase",
	"gitignore",
	"gitattributes",
	"json",
	"jsonc",
	"latex",
	"lua",
	"luadoc",
	"luap",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"ron",
	"toml",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
		lazy = false,
		config = function()
			require("nvim-treesitter").install(langs)
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter.setup", {}),
				callback = function(args)
					local buf = args.buf
					local ft = args.match
					local language = vim.treesitter.language.get_lang(ft) or ft
					if not vim.treesitter.language.add(language) then
						return
					end
					vim.treesitter.start(buf, language)
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "VeryLazy",
		branch = "main",
		keys = function()
			local function move_map(key, query, desc_name)
				return {
					{
						"[" .. key,
						function()
							require("nvim-treesitter-textobjects.move").goto_previous_start(query, "textobjects")
						end,
						desc = "Goto: prev " .. desc_name,
						mode = { "n", "x", "o" },
					},
					{
						"]" .. key,
						function()
							require("nvim-treesitter-textobjects.move").goto_next_start(query, "textobjects")
						end,
						desc = "Goto: next " .. desc_name,
						mode = { "n", "x", "o" },
					},
					{
						"[" .. key:upper(),
						function()
							require("nvim-treesitter-textobjects.move").goto_previous_end(query, "textobjects")
						end,
						desc = "Goto: prev " .. desc_name .. " end",
						mode = { "n", "x", "o" },
					},
					{
						"]" .. key:upper(),
						function()
							require("nvim-treesitter-textobjects.move").goto_next_end(query, "textobjects")
						end,
						desc = "Goto: next " .. desc_name .. " end",
						mode = { "n", "x", "o" },
					},
				}
			end

			local keymaps = {}
			vim.list_extend(keymaps, move_map("f", "@function.outer", "function"))
			vim.list_extend(keymaps, move_map("a", "@parameter.outer", "argument"))
			vim.list_extend(keymaps, move_map("c", "@class.outer", "class"))
			vim.list_extend(keymaps, move_map("o", "@code_cell.inner", "code cell"))
			vim.list_extend(keymaps, move_map("j", "@jps", "jps"))
			return keymaps
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
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
		end,
	},
}

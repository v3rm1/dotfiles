return {
	{
		"nvim-lualine/lualine.nvim",
		event = { "VeryLazy" },
		config = function()
			local lualine = require("lualine")
			lualine.setup({
				icons_enabled = true,
				theme = "catppuccin",
				options = {
					disabled_filetypes = {
						"packer",
						"NvimTree",
					},
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
					always_divide_middle = false,
					globalstatus = true,
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								return str:sub(1, 4)
							end,
						},
					},
					lualine_b = { "branch" },
					-- lualine_c = {},
					lualine_c = {
						{
							"buffers",
							show_filename_only = true,
							use_mode_colors = true,
						},
					},
					lualine_x = {
						{
							function()
								return "  " .. require("dap").status()
							end,
							cond = function()
								return package.loaded["dap"] and require("dap").status() ~= ""
							end,
							color = function()
								return { fg = Snacks.util.color("Debug") }
							end,
						},
						"lsp_status",
					},
					lualine_y = { "diagnostics", "diff", "filetype" },
					lualine_z = {
						"encoding",
						{ "location", padding = { left = 0, right = 1 } },
					},
				},
				extensions = { "lazy" },
			})
		end,
	},
}

return {
	{
		"danymat/neogen",
		config = function()
			require("neogen").setup({
				snippet_engine = "luasnip",
				languages = {
					python = {
						template = {
							annotation_convention = "numpydoc",
						},
					},
				},
			})
		end,
		-- Uncomment next line if you want to follow only stable versions
		-- version = "*"
		keys = {
			{
				"<leader>cn",
				function()
					require("neogen").generate()
				end,
				desc = "Generate Annotations (Neogen)",
			},
		},
	},
}

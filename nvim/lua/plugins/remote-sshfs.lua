return {
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("remote-sshfs").setup({
				connections = {
					ssh_configs = {
						vim.fn.expand("$HOME") .. "/.ssh/config",
					},
					sshfs_args = {
						"-o reconnect",
						"-o ConnectTimeout=5",
					},
				},
				mounts = {
					base_dir = vim.fn.expand("$HOME") .. "/.sshfs/",
					unmount_on_exit = true,
				},
				ui = {
					confirm = {
						connect = false,
					},
				},
				handlers = {
					on_connect = {
						change_dir = true,
					},
					on_disconnect = {
						clean_mount_folders = true,
					},
				},
			})
			require("telescope").load_extension("remote-sshfs")
		end,
	},
}

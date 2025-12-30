return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		open_mapping = [[<c-\>]],
		shade_filetypes = {},
		hide_numbers = true,
		shading_factor = 2,
		direction = "float",
		insert_mappings = true,
		close_on_exit = true,
		shell = vim.o.shell,
		float_opt = {
			border = "curved",
		},
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)
	end,
}

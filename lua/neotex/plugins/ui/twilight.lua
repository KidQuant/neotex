return {
	"folke/twilight.nvim",
	cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
	keys = {
		{ "<leader>ut", "<cmd>Twilight<CR>", desc = "Toggle Twilight" },
	},
	opts = {
		dimming = { alpha = 0.25 },
		context = 10,
		treesitter = true,
		expand = { "function", "method", "table", "if_statement" },
	},
}

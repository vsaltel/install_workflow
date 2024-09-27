return {
	-- "folke/tokyonight.nvim",
	"morhetz/gruvbox",
	priority = 1000,
	config = function()
		vim.cmd([[colorscheme gruvbox]])
		-- vim.cmd([[colorscheme tokyonight]])
	end,
}

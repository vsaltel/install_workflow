return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			sync_install = true,
			auto_install = true,

			highlight = {
				enable = true,
			},
			-- enable indentation
			indent = { enable = true },
			-- enable autotagging (w/ nvim-ts-autotag plugin)
			autotag = {
				enable = true,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"yaml",
				"html",
				"css",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"vimdoc",
				"cmake",
				"c",
				"cpp",
				"perl",
			},
			-- <S-h> (shift+h = H): init/grow ; <S-l> (shift+l = L): shrink
			-- Replaces the H/L defaults (top/bottom of screen), seen as less useful here
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<S-h>",
					node_incremental = "<S-h>",
					scope_incremental = false,
					node_decremental = "<S-l>",
				},
			},
		})
	end,
}

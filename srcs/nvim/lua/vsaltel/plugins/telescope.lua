return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sharkdp/fd",
		-- "nvim-treesitter/nvim-treesitter",
		{ "nvim-telescope/telescope-fzf-native.nvim",  build = "make" },
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-live-grep-args.nvim",
	},
	config = function()

		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
				defaults = {
					preview = {
						treesitter = false
					},
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
						}
					}
				}
			})

		telescope.load_extension("live_grep_args")
		telescope.load_extension("fzf");

		vim.api.nvim_create_user_command(
			'Config',
			function ()
				require('telescope.builtin').find_files({cwd="~/.config/nvim"})
			end,
			{}
		)
		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>r", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>s", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
		keymap.set("n", "<leader>w", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
	end
}

return {
	"sindrets/diffview.nvim",
	version = "*",
	keys = {
		{"<F6>", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
		{"<F7>", "<cmd>DiffviewClose<cr>", desc = "Close diff view" }
	},
	config = function()
		local actions = require("diffview.actions")

		require("diffview").setup {
			keymaps = {
				file_panel = {
					{ 'n', 't', actions.goto_file_tab }
				},
			},
		}
	end
}

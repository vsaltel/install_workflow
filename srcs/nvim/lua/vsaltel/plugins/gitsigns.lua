return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local gs = require("gitsigns")

		gs.setup()

		vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
		vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
		vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
		vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
		vim.keymap.set("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "Blame line" })
		vim.keymap.set("v", "<leader>hs", function()
			gs.stage_hunk({ [vim.fn.line({})] = true, [vim.fn.line({ "}" })] = true })
		end, { desc = "Stage hunk (visual)" })
	end,
}

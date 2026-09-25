return {
	'akinsho/toggleterm.nvim',
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")

		toggleterm.setup({
			open_mapping = [[<leader>Z]],
			direction = 'float',
		})

		local Terminal = require('toggleterm.terminal').Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

		vim.keymap.set("n", "<leader>z", function()
			lazygit:toggle()
		end, { desc = "Toggle lazygit" })
		vim.keymap.set("t", "<leader><Esc>", "<C-\\><C-n>", { desc = "Terminal: escape to normal mode" })
		vim.keymap.set("n", "<F8>", '<cmd>TermExec cmd="rs B150 -k KB150 -d firm -n firmware; exit"<CR>', { desc = "Build & flash firmware" })
	end
}

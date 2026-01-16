return {
	'akinsho/toggleterm.nvim',
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")

		toggleterm.setup({
			open_mapping = [[<leader>Z]],
			direction = 'float',
		})

		local Terminal  = require('toggleterm.terminal').Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

		function _lazygit_toggle()
			lazygit:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>z", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
		vim.api.nvim_set_keymap("t", "<leader><Esc>", "<c-\\><c-n>", {noremap = true, silent = true})

		vim.api.nvim_set_keymap("n", "<F8>", '<cmd>TermExec cmd="rs B150 -k KB150 -d firm -n firmware; exit"<CR>', {noremap = true, silent = true})
	end
}

return {
	"majutsushi/tagbar",
	config = function()
		vim.g.tagbar_autofocus = 1

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<F4>", "<cmd>TagbarToggle<CR>")
	end
}

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- disable default keybind
		vim.g.nvim_tree_disable_default_keybindings = 1

		-- disable netrw at the very start of your init.lua
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- optionally enable 24-bit colour
		vim.opt.termguicolors = true

		-- empty setup using defaults
		nvimtree.setup()

		-- OR setup with some options
		nvimtree.setup({
				sort = {
					sorter = "case_sensitive",
				},
				view = {
					width = 30,
				},
				renderer = {
					group_empty = true,
				},
				filters = {
					dotfiles = true,
				},
			})

		local function my_on_attach(bufnr)
			local api = require "nvim-tree.api"

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			-- default mappings
			api.config.mappings.default_on_attach(bufnr)

			-- custom mappings
			vim.keymap.del('n', '<Tab>', { buffer = bufnr })
 			vim.keymap.del('n', '<C-t>', { buffer = bufnr })
 			vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
			vim.keymap.del('n', 's', { buffer = bufnr })
 			vim.keymap.set('n', 's',  api.node.open.vertical, opts('Open: Vertical Split'))
  			vim.keymap.del('n', '<C-]>', { buffer = bufnr })
 			vim.keymap.set('n', '-',  api.tree.change_root_to_node, opts('CD'))
  			vim.keymap.set('n', '_',  api.tree.change_root_to_parent, opts('Up'))

		end

		nvimtree.setup({
				on_attach = my_on_attach,
			})

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<F2>", "<cmd>NvimTreeToggle<CR>")
		keymap.set("n", "<F3>", "<cmd>NvimTreeFindFileToggle<CR>")
		-- keymap.set("n", "<F4>", "<cmd>NvimTreeCollapse<CR>")
		-- keymap.set("n", "<F5>", "<cmd>NvimTreeRefresh<CR>")
	end
}

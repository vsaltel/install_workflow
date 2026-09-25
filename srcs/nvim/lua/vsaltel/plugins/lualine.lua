return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- fix behaviour github.com/nvim-lualine/lualine.nvim/issues/1312
		vim.api.nvim_set_hl(0, "Statusline", {reverse = false})
		vim.api.nvim_set_hl(0, "StatuslineNC", {reverse = false})

		local custom_gruvbox = require('lualine.themes.gruvbox')

	-- the "recording" (q) and "replay" (@) modes are not shown by default
	local lualine_mode = require('lualine.utils.mode')
	lualine_mode.map['rec'] = 'RECORDING'
	lualine_mode.map['r'] = 'REPLAY' -- lualine default: "REPLACE" (incorrect)

		custom_gruvbox.normal.a.bg = '#feaf01'   -- orange vif
		custom_gruvbox.normal.a.fg = '#282828'   -- contraste
		custom_gruvbox.normal.c.fg = '#ebdbb2'   -- gris clair
		custom_gruvbox.normal.c.gui = 'bold'

		custom_gruvbox.inactive.c.fg = '#aaaaa9'
		custom_gruvbox.inactive.a.fg = '#aaaaa9'

		require('lualine').setup {
			options = {
				icons_enabled = true,
				theme = custom_gruvbox,
				component_separators = { left = '', right = ''},
				section_separators = { left = '', right = ''},
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				}
			},
		sections = {
			-- single 'mode' component: a hidden second one would drop the section
			-- separator. mode() never returns 'rec', so we key off reg_recording().
			lualine_a = {
				{
					'mode',
					fmt = function(m)
						return vim.fn.reg_recording() ~= '' and 'RECORDING' or m
					end,
					-- the color fn's group doesn't inherit the theme 'gui', so bold
					-- is forced here; bg-only (not fg+bg) keeps the section separator
					color = function()
						return vim.fn.reg_recording() ~= ''
							and { bg = '#cc241d', gui = 'bold' }
							or { gui = 'bold' }
					end,
				},
			},
				lualine_b = {'branch', 'diff', 'diagnostics'},
				lualine_c = {
					{
						'filename',
						file_status = true,
						path = 3,
						shorting_target = 40,
						symbols = {
							modified = ' ●',       -- Text to show when the buffer is modified
							readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
							unnamed = '[No Name]', -- Text to show for unnamed buffers.
							newfile = '[New]',     -- Text to show for newly created file before first write
						},
					}
				},
				lualine_x = {'encoding', 'fileformat', 'filetype'},
				lualine_y = {'progress'},
				lualine_z = {'location'}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						'filename',
						file_status = true,
						path = 0,
						shorting_target = 40,
						symbols = {
							modified = ' ●',       -- Text to show when the buffer is modified
							readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
							unnamed = '[No Name]', -- Text to show for unnamed buffers.
							newfile = '[New]',     -- Text to show for newly created file before first write
						},
					}
				},
				lualine_x = {'location'},
				lualine_y = {},
				lualine_z = {}
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {'nvim-tree', 'lazy', 'toggleterm'}
		}
	end
}

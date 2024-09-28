return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    require('bufferline').setup({
		options = {
			mode = "tabs",
			separator_style = "slant",
			numbers = "ordinal",
			buffer_close_icon = '',
		},
		highlights = {
			fill = {
				fg = '#3a3a3a',
				bg = '#3a3a3a',
			},
			separator_selected = {
				bg = '#262626',
				fg = '#3a3a3a',
			},
			separator = {
				bg = '#3a3a3a',
				fg = '#3a3a3a',
			},
			tab_selected = {
				fg = '#feaf01',
				bg = '#feaf01',
			},
			numbers_selected = {
				fg = '#feaf01',
				bg = '#262626',
			},
			numbers = {
				fg = '#ffffff',
				bg = '#3a3a3a',
			},
			buffer_selected = {
				fg = '#feaf01',
				bg = '#262626',
				bold = true,
				italic = false,
			},
			duplicate_selected = {
				fg = '#feaf01',
				bg = '#262626',
				italic = true,
			},
			background = {
				fg = '#ffffff',
				bg = '#3a3a3a',
			},
			duplicate = {
				fg = '#ffffff',
				bg = '#3a3a3a',
			},
			close_button = {
				fg = '#3a3a3a',
				bg = '#3a3a3a',
			},
			tab_close = {
				fg = '#3a3a3a',
				bg = '#3a3a3a',
			},
            modified = {
                fg = '#a85228',
				bg = '#3a3a3a',
            },
            modified_selected = {
                fg = '#a85228',
				bg = '#262626',
            },
		},
	})
  end
}

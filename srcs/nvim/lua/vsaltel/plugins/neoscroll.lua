return {
	"karb94/neoscroll.nvim",
	opts = {},

	config = function()
		local scroll = require('neoscroll')
		scroll.setup({
			mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
				'<C-u>', '<C-d>',
				'<C-b>', '<C-f>',
				'<C-y>', '<C-e>',
				'zt', 'zz', 'zb',
			},
			hide_cursor = true,          -- Hide cursor while scrolling
			stop_eof = true,             -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
			duration_multiplier = 0.5,   -- Global duration multiplier (1.0 = default, < 1 = faster)
			easing = 'linear',           -- Default easing function
			pre_hook = nil,              -- Function to run before the scrolling animation starts
			post_hook = nil,             -- Function to run after the scrolling animation ends
			performance_mode = false,    -- Disable "Performance Mode" on all buffers.
			ignored_events = {           -- Events ignored while scrolling
				'WinScrolled', 'CursorMoved'
			},
		})

		-- Smooth half-screen scroll: <S-j> (down) / <S-k> (up).
		-- <S-j>/<S-k> have a non-scroll default (J/K), so explicit keymaps
		-- calling the same functions as <C-d>/<C-u> (half-screen, 250 ms).
		for _, mode in ipairs({ 'n', 'v', 'x' }) do
			vim.keymap.set(mode, '<S-j>', function()
				scroll.ctrl_d({ duration = 250 })
			end, { desc = 'Neoscroll: page down' })
			vim.keymap.set(mode, '<S-k>', function()
				scroll.ctrl_u({ duration = 250 })
			end, { desc = 'Neoscroll: page up' })
		end
	end
}

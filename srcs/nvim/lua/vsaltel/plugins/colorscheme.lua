return {
	"morhetz/gruvbox",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("gruvbox")

		-- Set TrailingWhitespace in red except in insert mode
		local function set_trailing_hl()
			vim.api.nvim_set_hl(0, "TrailingWhitespace", {
				bg = "#ff5555",
			})
		end

		set_trailing_hl()

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_trailing_hl,
		})

		local function enable_trailing_whitespace()
			vim.fn.clearmatches() -- window-local
			vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
		end

		local function disable_trailing_whitespace()
			vim.fn.clearmatches() -- window-local
		end

		vim.api.nvim_create_autocmd(
			{ "BufEnter", "BufWinEnter", "WinEnter", "InsertLeave" },
			{ callback = enable_trailing_whitespace }
		)

		vim.api.nvim_create_autocmd(
			{ "InsertEnter", "WinLeave" },
			{ callback = disable_trailing_whitespace }
		)
	end,
}

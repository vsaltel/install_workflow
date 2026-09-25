return {
	"morhetz/gruvbox",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("gruvbox")

		local function set_trailing_hl()
			vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#ff5555" })
		end
		set_trailing_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_trailing_hl })

		-- matchadd is window-local: the match survives buffer changes in the same
		-- window, and BufEnter does NOT fire when a terminal replaces the buffer
		-- (only TermOpen does) -> so we clean up explicitly per window
		local trail_ids = {}

		local function remove_trail()
			local win = vim.api.nvim_get_current_win()
			if trail_ids[win] then
				vim.fn.matchdelete(trail_ids[win])
				trail_ids[win] = nil
			end
		end

		local function sync_trail()
			remove_trail()
			local buf = vim.api.nvim_get_current_buf()
			if vim.bo[buf].buftype == "" then
				trail_ids[vim.api.nvim_get_current_win()] =
					vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
			end
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "InsertLeave" }, {
			callback = sync_trail,
		})
		vim.api.nvim_create_autocmd("InsertEnter", { callback = remove_trail })
		vim.api.nvim_create_autocmd("TermOpen", { callback = remove_trail })
		vim.api.nvim_create_autocmd("WinClosed", {
			callback = function(args) trail_ids[args.match] = nil end,
		})
	end,
}

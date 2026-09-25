vim.g.mapleader = ","

local keymap = vim.keymap

-- Move fast vertically
keymap.set({"n", "v"}, "J", "<C-d>", { desc = "Scroll down half page" })
keymap.set({"n", "v"}, "K", "<C-u>", { desc = "Scroll up half page" })

-- Jump Definition
keymap.set("n", "'", "<C-]>", { desc = "Jump to tag" })
keymap.set("n", "<leader>'", "<C-w><C-]>", { desc = "Jump to tag (vertical split)" })
keymap.set("n", ";", "<C-t>", { desc = "Jump back from tag" })

-- Open file under cursor
keymap.set("n", "glf", "<cmd>vertical wincmd f<CR>", { desc = "Open file under cursor (vertical split)" })
keymap.set("n", "gnf", "<C-w>f", { desc = "Open file under cursor (split)" })
keymap.set("n", "gtf", "<C-w>gf", { desc = "Follow file under cursor" })

-- Split
keymap.set("n", "<leader>h", "<cmd>split<CR>", { desc = "Horizontal split" })
keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })

-- Tabs
keymap.set("n", "<leader><Tab>", "gt", { desc = "Next tab" })
keymap.set("n", "<leader><S-Tab>", "gT", { desc = "Previous tab" })
keymap.set("n", "<leader>t", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>T", "<cmd>tab split<CR>", { desc = "Move current buffer to new tab" })
keymap.set("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
keymap.set("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
keymap.set("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
keymap.set("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
keymap.set("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
keymap.set("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
keymap.set("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
keymap.set("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
keymap.set("n", "<leader>9", "9gt", { desc = "Go to tab 9" })
keymap.set("n", "<leader>0", "<cmd>tablast<CR>", { desc = "Go to last tab" })

-- Buffer nav
keymap.set("n", "<leader>p", "<cmd>bp<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>n", "<cmd>bn<CR>", { desc = "Next buffer" })

-- Close buffer
keymap.set("n", "<leader>c", "<cmd>bd<CR>", { desc = "Close buffer" })

-- Quickfix
keymap.set("n", "<leader>q", "<cmd>copen<CR>", { desc = "Open quickfix" })
keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })

-- Join lines
keymap.set("n", "<C-n>", "J", { desc = "Join lines" })

-- Switching windows
keymap.set("n", "<Tab>", "<C-w><C-w>", { desc = "Cycle windows" })

-- Recording feedback: ModeChanged doesn't fire on record start/stop, so we
-- poll reg_recording() and refresh lualine on change. (q stops, not Esc.)
do
	local last = ""
	local function check()
		local now = vim.fn.reg_recording()
		if now ~= last then
			last = now
			pcall(function()
				require("lualine").refresh()
			end)
		end
		vim.defer_fn(check, 100)
	end
	check()
end

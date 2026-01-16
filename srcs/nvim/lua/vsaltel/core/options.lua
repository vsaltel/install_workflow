vim.cmd("let g:netrw_liststyle = 3")

-- prevent vertical split from being resized
vim.cmd("vertical resize nomodify")

-- prevent adding a newline at the end of a file
vim.cmd("set nofixeol")

local opt = vim.opt

-- refresh time
opt.lazyredraw = true
opt.updatetime = 250

-- line number
opt.relativenumber = true
opt.number = true
opt.ruler = true
opt.cursorline = true

-- tabs & indentation
opt.tabstop = 4
opt.softtabstop = 0
opt.shiftwidth = 4
opt.expandtab = false -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- timeout for escape key (10 ms)
opt.timeoutlen=1000
opt.ttimeoutlen=0

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- if you include mixed case in your search, assumes you want case-sensitive
opt.wrapscan = true   -- search in top if not found in bot
opt.gdefault = true   -- :subtitute is global

-- turn on termguicolors for tokyonight colorscheme to work
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

opt.diffopt = vertical
opt.hidden = true

-- searching
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- mouse settings
opt.mouse = "a"
opt.mousemodel = "popup"
opt.mousefocus = true
opt.mousehide = true

-- scroll limiter
opt.sidescrolloff = 8
opt.scrolloff = 8

-- status bar
opt.showmode = false
opt.showcmd = false
opt.cmdheight = 1
opt.laststatus = 2

-- autoread when files get update
opt.autoread = true

-- indentation improvement
opt.smartindent = true
opt.shiftround = true

opt.colorcolumn = "90"

-- highlight current line on the cursor
opt.cursorline = true

-- highlight special chars
opt.list = true
opt.listchars = {
	tab = "--⮞",
	extends = "»",
	precedes = "«",
	-- space = "·",
	-- trail = "·",
}

-- Set TrailingWhitespace in red except in insert mode
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "TrailingWhitespace", {
			bg = "#ff5555"
		})
	end,
})

local function enable_trailing_whitespace()
	vim.fn.clearmatches()
	vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
end

local function disable_trailing_whitespace()
	vim.fn.clearmatches()
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave" }, {
	callback = enable_trailing_whitespace,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = disable_trailing_whitespace,
})

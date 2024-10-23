vim.cmd("let g:netrw_liststyle = 3")

-- prevent vertical split from being resized
vim.cmd("vertical resize nomodify")

local opt = vim.opt

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
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
-- opt.clipboard:append("unnamedplus") -- use system clipboard as default register

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

-- comment italic
vim.api.nvim_set_hl(0, 'Comment', { italic=true })

-- mouse settings
opt.mouse = "a"
opt.mousemodel = popup

-- scroll limiter
opt.scrolloff = 5

-- status bar
opt.laststatus = 2

-- autoread when files get update
opt.autoread = true

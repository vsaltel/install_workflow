vim.cmd("let g:netrw_liststyle = 3")

-- prevent adding a newline at the end of a file
vim.cmd("set nofixeol")

local opt = vim.opt

-- winfixwidth/height=false so `equalalways` can equalize splits
-- (true gave uneven splits when opening files from nvim-tree).
opt.winfixwidth = false
opt.winfixheight = false

-- refresh time
opt.lazyredraw = true
opt.updatetime = 400
opt.ttyfast = true

-- line number
opt.relativenumber = true
opt.number = true
opt.ruler = true
opt.cursorline = true

-- tabs & indentation
opt.tabstop = 4
opt.softtabstop = 0
opt.shiftwidth = 4
opt.expandtab = false -- utilise de vrais tabs (pas d'expansion en espaces)
opt.autoindent = true -- copy indent from indent line when starting a new line

opt.wrap = false

-- timeout for key sequences (e.g. ,c vs ,ca)
-- 800: value recommended by which-key (stable menu) — single source, which-key no longer overrides it
opt.timeoutlen = 800
opt.ttimeoutlen = 0

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- if you include mixed case in your search, assumes you want case-sensitive
opt.wrapscan = true   -- search in top if not found in bot
opt.gdefault = true   -- :substitute is global

-- turn on termguicolors for tokyonight colorscheme to work
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "auto:1" -- dont show sign column if sign list is empty

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line and insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom
opt.splitkeep = "screen" -- the cursor keeps its screen position on split/resize
opt.pumheight = 10 -- completion menu limited to 10 lines

-- live preview of :s/// in a window before confirming
opt.inccommand = "split"

-- native completion (Ctrl-X Ctrl-L): same rules as nvim-cmp
opt.completeopt = "menu,menuone,noselect"

-- rounded borders for floating windows (0.11+)
opt.winborder = "rounded"

-- less noise in the command line:
-- F filename on open, I intro message, C "scanning tags", o "overwriting", t/s search messages, u undo/redo
opt.shortmess:append("FICotsu")

-- historique de commandes
opt.history = 1000

-- turn off swapfile
opt.swapfile = false

-- undo persistant (l'historique d'undo survit au reboot)
opt.undofile = true
if vim.fn.exists("&unddir") == 2 then
	opt.unddir = vim.fn.stdpath("state") .. "/undo"
end

opt.diffopt:append("vertical")
opt.hidden = true

-- searching
opt.hlsearch = true
opt.incsearch = true

-- mouse settings
opt.mouse = "a"
opt.mousemodel = "popup"
opt.mousefocus = true
opt.mousehide = true

-- scroll limiter
opt.sidescrolloff = 8
opt.scrolloff = 999 -- previous 8

-- status bar
opt.showmode = false
opt.showcmd = true
opt.laststatus = 2
opt.cmdheight = 1

-- autoread when files get update
opt.autoread = true

-- indentation improvement
opt.smartindent = true
opt.shiftround = true

-- highlight special chars
opt.list = true
opt.listchars = {
	tab = "→·",
	extends = "»",
	precedes = "«",
}

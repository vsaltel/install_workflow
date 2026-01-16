vim.g.mapleader = ","

local keymap = vim.keymap

-- Move fast verticaly
keymap.set({"n", "v"}, "J", "<C-d>")
keymap.set({"n", "v"}, "K", "<C-u>")

-- Jump Definition
keymap.set("n", "'", "<C-]>")
keymap.set("n", "<leader>'", "<C-w><C-]>")
keymap.set("n", ";", "<C-t>")

-- Open file under cursor
keymap.set("n", "glf", "<cmd>vertical wincmd f<CR>")
keymap.set("n", "gnf", "<C-w>f")
keymap.set("n", "gtf", "<C-w>gf")

-- Split
keymap.set("n", "<leader>h", "<cmd>split<CR>")
keymap.set("n", "<leader>v", "<cmd>vsplit<CR>")

-- Tabs
keymap.set("n", "<leader><Tab>", "gt")
keymap.set("n", "<leader><S-Tab>", "gT")
keymap.set("n", "<leader>t", "<cmd>tabnew<CR>")
keymap.set("n", "<leader>T", "<cmd>tab split<CR>")
keymap.set("n", "<leader>1", "1gt")
keymap.set("n", "<leader>2", "2gt")
keymap.set("n", "<leader>3", "3gt")
keymap.set("n", "<leader>4", "4gt")
keymap.set("n", "<leader>5", "5gt")
keymap.set("n", "<leader>6", "6gt")
keymap.set("n", "<leader>7", "7gt")
keymap.set("n", "<leader>8", "8gt")
keymap.set("n", "<leader>9", "9gt")
keymap.set("n", "<leader>0", "<cmd>tablast<CR>.")

-- Buffer nav
keymap.set("n", "<leader>p", "<cmd>bp<CR>")
keymap.set("n", "<leader>n", "<cmd>bn<CR>")

-- Close buffer
keymap.set("n", "<leader>c", "<cmd>bd<CR>")

-- Join lines
keymap.set("n", "<C-n>", "J")

-- Switching windows
keymap.set("n", "<Tab>", "<C-w><C-w>")

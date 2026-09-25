-- Diagnostic config
-- on_jump: replaces jump.float (deprecated in 0.13, removed in 0.14)
local function on_jump(diagnostic, bufnr)
	if diagnostic then
		vim.diagnostic.open_float(diagnostic)
	end
end

vim.diagnostic.config({
	float = {
		source = false,
		border = 'double',
		severity_sort = true,
	},
	virtual_text = {
		source = true,
		prefix = '●',
		spacing = 4,
		virt_text_pos = 'eol',
		hl_mode = 'combine',
	},
	virtual_lines = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = ' ',
			[vim.diagnostic.severity.WARN] = ' ',
			[vim.diagnostic.severity.INFO] = ' ',
			[vim.diagnostic.severity.HINT] = ' ',
		},
	},
	underline = true,
	severity_sort = true,
	jump = {
		on_jump = on_jump,
	},
	update_in_insert = false,
})

local border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
local open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, options, ...)
	options = options or {}
	options.border = options.border or border
	return open_floating_preview(contents, syntax, options, ...)
end

--- Setup mapping when attaching LSP server
---@param client table LSP client
---@param bufnr integer Buffer number
local function lsp_keymaps(client, bufnr)
	--- Wrapper function to set keymap
	---@param m string|table The modes
	---@param lhs string Keymap
	---@param rhs string|function Command called when pressing keymap
	---@param desc string Keymap description
	local kmap = function(m, lhs, rhs, desc)
		local opts = { remap = false, silent = true, buffer = bufnr, desc = desc }
		vim.keymap.set(m, lhs, rhs, opts)
	end

	-- Set some keybinds conditional on server capabilities
	-- if client:supports_method('textDocument/formatting') then
	-- 	kmap('n', '<leader>f', function()
	-- 		vim.lsp.buf.format({ async = true })
	-- 	end, 'Format current buffer with LSP')
	-- end

	-- LSP keymaps
	kmap("n", "gR", vim.lsp.buf.references, "Show LSP references")
	kmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
	kmap("n", "gd", vim.lsp.buf.definition, "Show LSP definitions")
	kmap("n", "gi", vim.lsp.buf.implementation, "Show LSP implementations")
	kmap("n", "gt", vim.lsp.buf.type_definition, "Show LSP type definitions")
	kmap('n', "gk", vim.lsp.buf.signature_help, "Signature Documentation")
	kmap("n", "gK", vim.lsp.buf.hover, "Show documentation for what is under cursor")
	kmap("n", "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
	kmap("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")

	-- Diagnostics keymaps
	local function Toggle_diagnostics()
		vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	end
	kmap("n", "<F5>", Toggle_diagnostics, "Toggle diagnostic")
	kmap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
	kmap("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
	kmap("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
	kmap("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")

end

local function lsp_document_highlight(bufnr)
	local gid = vim.api.nvim_create_augroup('LSPDocumentHighlight', { clear = false })
	vim.api.nvim_clear_autocmds({
		group = gid,
		buffer = bufnr,
	})

	vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
		group = gid,
		desc = 'Highlight document using LSP server capabilities',
		buffer = bufnr,
		callback = vim.lsp.buf.document_highlight,
	})
	vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
		group = gid,
		desc = 'Clear document highlights using LSP server capabilities',
		buffer = bufnr,
		callback = vim.lsp.buf.clear_references,
	})
end

--- Create augroup and autocommands for InlayHints
---@param bufnr integer Buffer number
local function lsp_inlay_hints(bufnr)
	local gid = vim.api.nvim_create_augroup('LSPInlayHints', { clear = false })
	vim.api.nvim_clear_autocmds({
		group = gid,
		buffer = bufnr,
	})

	-- Initial inlay hint display.
	local mode = vim.api.nvim_get_mode().mode
	if mode == 'n' or mode == 'v' then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	vim.api.nvim_create_autocmd('InsertEnter', {
		group = gid,
		desc = 'Disable the inlay hints',
		buffer = bufnr,
		callback = function()
			vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
		end,
	})
	vim.api.nvim_create_autocmd('InsertLeave', {
		group = gid,
		desc = 'Enable the inlay hints',
		buffer = bufnr,
		callback = function()
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end,
	})
end

local function on_attach(client, bufnr)
	lsp_keymaps(client, bufnr)

	-- Format
	-- vim.keymap.set({ 'n', 'x' }, '<leader>F', function()
	--     vim.lsp.buf.format({ async = true })
	-- end, opts)

	-- Inlay hints
	if vim.g.inlay_hint_enabled then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
	-- Toggle (buffer-local)
	vim.keymap.set('n', '\\h', function()
		local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
		vim.b.inlay_hint_enabled = not is_enabled
		vim.lsp.inlay_hint.enable(vim.b.inlay_hint_enabled, { bufnr = 0 })

		vim.notify(
			string.format('Inlay hints (buffer-local) is %s', vim.b.inlay_hint_enabled and 'enabled' or 'disabled'),
			vim.log.levels.INFO
		)
	end, {})

	-- Toggle (global)
	vim.keymap.set('n', '\\H', function()
		vim.g.inlay_hint_enabled = not vim.g.inlay_hint_enabled
		vim.lsp.inlay_hint.enable(vim.g.inlay_hint_enabled)
		vim.notify(
			string.format('Inlay hints (global) is %s', vim.g.inlay_hint_enabled and 'enabled' or 'disabled'),
			vim.log.levels.INFO
		)
	end, {})

	-- Lsp progress
	-- require('rockyz.lsp.progress')

	-- Show a lightbulb when code actions are available under the cursor
	-- require('rockyz.lsp.lightbulb')

	-- Enable code lens
	-- if client and client.server_capabilities.codeLensProvider then
	--     vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
	--         buffer = bufnr,
	--         callback = function()
	--             vim.lsp.codelens.refresh({ bufnr = 0 })
	--         end,
	--     })
	-- end

	-- Document highlight
	if client:supports_method('textDocument/InlayHint') then
		lsp_inlay_hints(bufnr)
	else
		vim.notify('Server not supporting', vim.log.levels.INFO, { title = 'InlayHints' })
	end

	if client:supports_method('textDocument/documentHighlight') then
		lsp_document_highlight(bufnr)
	end
end

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		on_attach(client, bufnr)
	end,
})

vim.lsp.config('*', {
	root_markers = {
		'.git',
	},
})

vim.lsp.enable({
	'clangd', -- C / C++
	-- 'jsonls', -- JSON / JSONC
	-- 'yamlls', -- Yaml
	-- 'bashls', -- Shell
	-- 'luals', -- Lua
	-- 'pyright', -- Python
	-- 'ruff', -- Python
	-- 'cmake', -- CMake
	-- 'cssls', -- CSS
	-- 'rust_analyzer', -- Rust
	-- 'texlab', -- LaTeX
	-- 'ansiblels', -- Ansible
	-- 'composels', -- Docker compose
	-- 'tombi', -- Toml
	-- 'tailwindcss', -- Tailwindcss
	-- 'perlnavigator', -- Perl
})

local map = function(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	if opts.remap and not vim.g.vscode then
		opts.remap = nil
	end
	vim.keymap.set(mode, lhs, rhs, opts)
end

--- Normal Mode ---
-- Better Up/Down --
map("n", "j", [[v:count ? 'j' : 'gj']], { desc = "Down", expr = true })
map("n", "k", [[v:count ? 'k' : 'gk']], { desc = "Up", expr = true })

-- Visual Block Remap --
map("n", "<Leader>b", "<C-v>", { desc = "Visual Block" })

-- Move Window --
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Split Window --
map("n", "<Leader>v", "<C-w>v", { desc = "Vertical Split" })
map("n", "<Leader>s", "<C-w>s", { desc = "Horizontal Split" })
map("n", "<Leader>,", "<CMD>vertical resize -10<CR>", { desc = "Move Window to Left" })
map("n", "<Leader>.", "<CMD>vertical resize +10<CR>", { desc = "Move Window to Right" })
map("n", "<Leader>-", "<CMD>resize -10<CR>", { desc = "Move Window to Upper" })
map("n", "<Leader>+", "<CMD>resize +10<CR>", { desc = "Move Window to Lower" })
map("n", "<Leader>=", "<C-w>=", { desc = "Balance Window" })

-- Close Window --
map("n", "<Leader>q", "<CMD>q<CR>", { desc = "Close Window" })
map("n", "<Leader>w", "<CMD>w<CR>", { desc = "Save Window" })
map("n", "<Leader>wq", "<CMD>wq<CR>", { desc = "Save and Close Window" })
map("n", "<Leader>wqa", "<CMD>wqa<CR>", { desc = "Save and Close all Windows" })
map("n", "<Leader>cq", "<CMD>cq<CR>", { desc = "Close Window without Modify" })

-- Jump --
map("n", "<Leader>[", "<C-o>", { desc = "Jump Prev" })
map("n", "<Leader>]", "<C-i>", { desc = "Jump Next" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Jump to Definition" })
map("n", "gt", "<C-]>", { desc = "Jump to Tag" })

-- Clear Search Hightlight --
map("n", "<Leader>c", "<CMD>noh<CR>", { desc = "Clear Search Highlight" })

-- Buffer --
map("n", "<Leader>bh", "<CMD>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<Leader>bl", "<CMD>bnext<CR>", { desc = "Next Buffer" })
map("n", "<Leader>bq", "<CMD>bd<CR>", { desc = "Delete Buffer" })

--- Terminal Mode ---
-- ESC --
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal Escape", noremap = true })

--- Incremental Selection ---
vim.keymap.set({ "n", "x", "o" }, "<A-[>", function()
	require("vim.treesitter._select").select_prev(vim.v.count1)
end, { desc = "Select previous node" })

vim.keymap.set({ "n", "x", "o" }, "<A-]>", function()
	require("vim.treesitter._select").select_next(vim.v.count1)
end, { desc = "Select next node" })
vim.keymap.set({ "n", "x", "o" }, "<A-o>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_parent(vim.v.count1)
	else
		vim.lsp.buf.selection_range(vim.v.count1)
	end
end, { desc = "Select parent (outer) node" })

vim.keymap.set({ "n", "x", "o" }, "<A-i>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_child(vim.v.count1)
	else
		vim.lsp.buf.selection_range(-vim.v.count1)
	end
end, { desc = "Select child (inner) node" })

--- Restart Neovim ---
vim.keymap.set("n", "<leader>r", function()
	local session = vim.fn.stdpath("state") .. "/restart_session.vim"
	vim.cmd("mksession! " .. vim.fn.fnameescape(session))
	vim.cmd("restart source " .. vim.fn.fnameescape(session))
end, { desc = "Restart Neovim" })

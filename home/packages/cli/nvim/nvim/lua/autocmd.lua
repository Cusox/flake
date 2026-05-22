local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local group = augroup("nvim_group", { clear = true })

-- Highlight after Yank
autocmd("TextYankPost", {
	group = group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

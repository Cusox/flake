local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Pi
	vim.pack.add({
		gh("pablopunk/pi.nvim"),
	})
	require("pi").setup()
	vim.keymap.set("n", "<leader>ai", ":PiAsk<CR>", { desc = "Ask pi" })
	vim.keymap.set("v", "<leader>ai", ":PiAskSelection<CR>", { desc = "Ask pi (selection)" })
	vim.keymap.set("n", "<leader>aic", ":PiCancel<CR>", { desc = "Cancel pi" })
end

return M

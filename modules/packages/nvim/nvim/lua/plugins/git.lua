local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.pack.add({
		gh("lewis6991/gitsigns.nvim"),
		gh("dlyongemallo/diffview.nvim"),
		gh("neogitorg/neogit"),
		gh("NicholasZolton/neojj"),
	})
	require("neogit").setup()
	vim.keymap.set("n", "<leader>g", function()
		require("neogit").open()
	end, { desc = "Open Neogit" })
	require("neojj").setup()
	vim.keymap.set("n", "<leader>gg", function()
		require("neojj").open()
	end, { desc = "Open Neojj" })
end

return M

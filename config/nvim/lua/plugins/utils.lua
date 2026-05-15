local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Plenary
	vim.pack.add({
		gh("nvim-lua/plenary.nvim"),
	})

	-- Search
	vim.pack.add({
		gh("ibhagwan/fzf-lua"),
	})
	vim.keymap.set("n", "<C-p>", function()
		require("fzf-lua").files()
	end, { desc = "Fzf Browse Files" })
	vim.keymap.set("n", "<C-b>", function()
		require("fzf-lua").buffers()
	end, { desc = "Fzf Browse Buffers" })
	vim.keymap.set("n", "<C-f>", function()
		require("fzf-lua").grep()
	end, { desc = "Fzf Grep" })
end

return M

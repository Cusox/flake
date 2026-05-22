local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Treesitter
	vim.api.nvim_create_autocmd("FileType", {
		desc = "enable treesitter, install parser if missing",
		callback = function()
            pcall(vim.treesitter.start)
		end,
	})

	-- Treesitter Context
	vim.api.nvim_create_autocmd("BufReadPre", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("nvim-treesitter/nvim-treesitter-context"),
			})
		end,
	})
end

return M

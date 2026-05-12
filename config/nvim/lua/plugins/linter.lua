local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	vim.api.nvim_create_autocmd("BufReadPre", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("mfussenegger/nvim-lint"),
			})
			require("lint").linters_by_ft = {
				sh = { "shellcheck" },
				python = { "ruff" },
			}

			vim.keymap.set("n", "<Leader>l", function()
				require("lint").try_lint()
			end, { desc = "Lint buffer" })
		end,
	})
end

return M

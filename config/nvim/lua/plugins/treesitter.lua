local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Treesitter

	vim.api.nvim_create_autocmd("FileType", {
		desc = "enable treesitter, install parser if missing",
		callback = function(event)
            if pcall(vim.treesitter.start) then
                return
            end

			local lang = vim.treesitter.language.get_lang(event.match)
            if not lang then
                return
            end

            local ok, treesitter = pcall(require, "nvim-treesitter")
            if not ok then
                return
            end

			treesitter.install(lang):await(function()
				pcall(vim.treesitter.start, event.buf, lang)
			end)
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

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

	-- Chezmoi
	vim.pack.add({
		gh("xvzc/chezmoi.nvim"),
	})
	require("chezmoi").setup({})
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = { (vim.fn.expand("~")):gsub("\\", "/") .. "/.local/share/chezmoi/*" },
		callback = function(ev)
			local bufnr = ev.buf
			local edit_watch = function()
				require("chezmoi.commands.__edit").watch(bufnr)
			end
			vim.schedule(edit_watch)
		end,
	})

	local fzf_chezmoi = function()
		local chezmoi_commands = require("chezmoi.commands")

		require("fzf-lua").fzf_exec(chezmoi_commands.list(), {
			actions = {
				["default"] = function(selected, opts)
					require("chezmoi.commands").edit({
						targets = { "~/" .. selected[1] },
						args = { "--watch" },
					})
				end,
			},
		})
	end

	vim.api.nvim_create_user_command("ChezmoiFzf", fzf_chezmoi, {})
end

return M

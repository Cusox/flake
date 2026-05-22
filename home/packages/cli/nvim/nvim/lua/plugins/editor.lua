local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end
local cb = function(x)
	return "https://codeberg.org/" .. x
end

function M.setup()
	-- Undotree
	vim.cmd.packadd("nvim.undotree")
	vim.keymap.set("n", "<leader>u", require("undotree").open)

	-- Keymap
	vim.pack.add({
		gh("folke/which-key.nvim"),
		gh("m4xshen/hardtime.nvim"),
	})
	require("which-key").setup()
	vim.keymap.set("n", "<leader>?", function()
		require("which-key").show({ global = false })
	end, { desc = "Buffer Local Keymaps (which-key)" })
	require("hardtime").setup()

	-- Session
	vim.pack.add({
		gh("folke/persistence.nvim"),
	})
	require("persistence").setup()
	vim.keymap.set("n", "<leader>sd", function()
		require("persistence").load()
	end, { desc = "Load Current Session" })
	vim.keymap.set("n", "<leader>sf", function()
		require("persistence").select()
	end, { desc = "Select a Session" })
	vim.keymap.set("n", "<leader>ss", function()
		require("persistence").load({ last = true })
	end, { desc = "Load Last Session" })

	-- File Explorer
	vim.pack.add({
		gh("nvim-mini/mini.files"),
	})
	require("mini.files").setup()
	vim.keymap.set("n", "<leader>t", function()
		MiniFiles.open()
	end, { desc = "open file explorer" })

	-- Motion
	vim.pack.add({
		cb("andyg/leap.nvim"),
	})
	vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
	vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
	vim.keymap.set({ "x", "o" }, "<Space>", function()
		require("leap.treesitter").select({
			opts = require("leap.user").with_traversal_keys("<Space>", "<Backspace>"),
		})
	end)

	vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })

	require("leap.user").set_repeat_keys("<Enter>", "<Backspace>")
	require("leap").opts.preview = false
	require("leap").opts.equivalence_classes = {
		" \t\r\n",
		"([{",
		")]}",
		"'\"`",
	}

	-- Annotation
	vim.pack.add({
		gh("jeangiraldoo/codedocs.nvim"),
	})
	vim.keymap.set("n", "gck", "<cmd>Codedocs<CR>", { desc = "Insert annotation" })

	vim.pack.add({
		gh("Cartoone9/pretty-comment.nvim"),
	})
	require("pretty-comment").setup()
	vim.keymap.set("v", "gcb", ":CommentBox<CR>", { silent = true, desc = "Comment box" })
	vim.keymap.set("n", "gcb", "<cmd>CommentBox<CR>", { silent = true, desc = "Comment box (line)" })
	vim.keymap.set("v", "gcB", ":CommentBoxFat<CR>", { silent = true, desc = "Fat comment box" })
	vim.keymap.set("n", "gcB", "<cmd>CommentBoxFat<CR>", { silent = true, desc = "Fat comment box (line)" })
	vim.keymap.set("v", "gcl", ":CommentLine<CR>", { silent = true, desc = "Centered title line" })
	vim.keymap.set("n", "gcl", "<cmd>CommentLine<CR>", { silent = true, desc = "Centered title line (line)" })
	vim.keymap.set("v", "gcL", ":CommentLineFat<CR>", { silent = true, desc = "Fat centered title line" })
	vim.keymap.set("n", "gcL", "<cmd>CommentLineFat<CR>", { silent = true, desc = "Fat centered title line (line)" })
	vim.keymap.set("n", "gcs", "<cmd>CommentSep<CR>", { silent = true, desc = "Comment separator" })
	vim.keymap.set("n", "gcS", "<cmd>CommentSepFat<CR>", { silent = true, desc = "Fat comment separator" })
	vim.keymap.set("n", "gcd", "<cmd>CommentDiv<CR>", { silent = true, desc = "Comment divider" })
	vim.keymap.set("n", "gcD", "<cmd>CommentDivFat<CR>", { silent = true, desc = "Fat comment divider" })
	vim.keymap.set("v", "gcr", ":CommentRemove<CR>", { silent = true, desc = "Strip comment decoration" })
	vim.keymap.set("n", "gcr", "<cmd>CommentRemove<CR>", { silent = true, desc = "Strip comment decoration (line)" })
	vim.keymap.set(
		"v",
		"gce",
		":CommentEqualize<CR>",
		{ silent = true, desc = "Equalize comment decoration (selection)" }
	)
	vim.keymap.set("n", "gce", "<cmd>CommentEqualize<CR>", { silent = true, desc = "Equalize all comment decoration" })
	vim.keymap.set("n", "gcx", "<cmd>CommentReset<CR>", { silent = true, desc = "Reset comment width tracking" })
	vim.keymap.set("x", "gcc", function()
		return require("vim._comment").operator()
	end, { expr = true, desc = "Comment toggle (instant, avoids gc delay)" })

	-- CodeAction
	vim.api.nvim_create_autocmd("LspAttach", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("rachartier/tiny-code-action.nvim"),
			})
			require("tiny-code-action").setup({
				backend = "delta",
				picker = "fzf-lua",
			})
		end,
	})
end

return M

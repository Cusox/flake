local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- UI2
	local ui2 = require("vim._core.ui2")
	local msgs = require("vim._core.ui2.messages")

	ui2.enable({
		enable = true,
		targets = {
			[""] = "msg",
			empty = "cmd",
			bufwrite = "msg",
			confirm = "cmd",
			emsg = "pager",
			echo = "msg",
			echomsg = "msg",
			echoerr = "pager",
			completion = "cmd",
			list_cmd = "pager",
			lua_error = "pager",
			lua_print = "msg",
			progress = "pager",
			rpc_error = "pager",
			quickfix = "msg",
			search_cmd = "cmd",
			search_count = "cmd",
			shell_cmd = "pager",
			shell_err = "pager",
			shell_out = "pager",
			shell_ret = "msg",
			undo = "msg",
			verbose = "pager",
			wildlist = "cmd",
			wmsg = "msg",
			typed_cmd = "cmd",
		},
		cmd = {
			height = 0.5,
		},
		dialog = {
			height = 0.5,
		},
		msg = {
			height = 0.3,
			timeout = 5000,
		},
		pager = {
			height = 0.5,
		},
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "msg",
		callback = function()
			local ui2 = require("vim._core.ui2")
			local win = ui2.wins and ui2.wins.msg
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_set_option_value(
					"winhighlight",
					"Normal:NormalFloat,FloatBorder:FloatBorder",
					{ scope = "local", win = win }
				)
			end
		end,
	})

	local orig_set_pos = msgs.set_pos
	msgs.set_pos = function(tgt)
		orig_set_pos(tgt)
		if (tgt == "msg" or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
			pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
				relative = "editor",
				anchor = "NE",
				row = 1,
				col = vim.o.columns - 1,
				border = "rounded",
			})
		end
	end

	vim.api.nvim_create_autocmd("LspProgress", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			local value = ev.data.params.value
			local msg = ("[%s] %s %s"):format(client.name, value.kind == "end" and "✓" or "", value.title or "")
			vim.notify(msg)
		end,
	})

	-- UI Component Library
	vim.pack.add({
		gh("MunifTanjim/nui.nvim"),
	})

	-- Icons
	vim.pack.add({
		gh("nvim-tree/nvim-web-devicons"),
		gh("nvim-mini/mini.icons"),
	})

	-- Lualine
	vim.pack.add({
		gh("nvim-lualine/lualine.nvim"),
	})
	require("lualine").setup({
		options = {
			theme = "nordic",
			component_separators = { left = "│", right = "│" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				"diff",
				"diagnostics",
				{
					"buffers",
					mode = 2,
					max_length = vim.o.columns / 2,
					buffers_color = {
						active = { bg = "#434C5E", fg = "#81A1C1", gui = "bold" },
						inactive = { bg = "#2A2F3A", fg = "#3B4252", gui = "italic" },
					},
					symbols = {
						modified = " ●",
						alternate_file = "",
						directory = "",
					},
				},
			},
			lualine_c = {
				{
					"filename",
					file_status = true,
					path = 3,
					shorting_target = 0,
				},
			},
			lualine_x = {},
			lualine_y = {
				"searchcount",
				"selectioncount",
				"encoding",
				"filetype",
				{
					function()
						local icon = " "
						local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
						if #clients == 0 then
							return " "
						end

						local is_fetching = false
						for _, req in pairs(clients[1].requests or {}) do
							if req.type == "pending" then
								is_fetching = true
								break
							end
						end

						if is_fetching then
							return icon .. "..."
						end

						return icon
					end,
					color = function()
						local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
						if #clients == 0 then
							return { fg = "#4C566A" }
						end

						for _, req in pairs(clients[1].requests or {}) do
							if req.type == "pending" then
								return { fg = "#EBCB8B" }
							end
						end

						return { fg = "#A3BE8C" }
					end,
				},
			},
			lualine_z = {
				"progress",
				"location",
			},
		},
	})

	-- Indent
	vim.api.nvim_create_autocmd("BufReadPre", {
		once = true,
		callback = function()
			vim.pack.add({
				gh("nvim-mini/mini.indentscope"),
			})
			require("mini.indentscope").setup({
				options = {
					try_as_border = true,
				},
				symbol = "│",
			})
		end,
	})

	-- Scroll
	vim.pack.add({
		gh("karb94/neoscroll.nvim"),
	})
	require("neoscroll").setup({
		mappings = {
			"<C-u>",
			"<C-d>",
			"<C-y>",
			"<C-e>",
		},
		easing = "sine",
		hide_cursor = false,
	})

	-- Diagnostic Message
	vim.pack.add({
		gh("rachartier/tiny-inline-diagnostic.nvim"),
	})
	require("tiny-inline-diagnostic").setup()
	vim.diagnostic.config({
		virtual_text = false,
	})

	-- Animations
	vim.pack.add({
		gh("rachartier/tiny-glimmer.nvim"),
	})
	require("tiny-glimmer").setup({
		overwrite = {
			search = {
				enabled = true,
			},
			undo = {
				enabled = true,
			},
			redo = {
				enabled = true,
			},
		},
	})

	-- CMDLine
	vim.pack.add({
		gh("rachartier/tiny-cmdline.nvim"),
	})
	require("tiny-cmdline").setup({
		on_reposition = require("tiny-cmdline").adapters.blink,
	})
	vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { fg = "#8FBCBB" })
	vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { bg = "#242933" })
end

return M

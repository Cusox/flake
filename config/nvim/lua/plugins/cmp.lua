local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end

function M.setup()
	-- Lazydev
	vim.pack.add({
		gh("folke/lazydev.nvim"),
	})
	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

	-- Surround
	vim.pack.add({
		gh("kylechui/nvim-surround"),
	})

	-- Blink.cmp
	vim.pack.add({
		gh("saghen/blink.lib"),
		gh("xzbdmw/colorful-menu.nvim"),
		gh("rafamadriz/friendly-snippets"),
		gh("mikavilpas/blink-ripgrep.nvim"),
		gh("fang2hou/blink-copilot"),
		gh("disrupted/blink-cmp-conventional-commits"),
		{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	})
	require("blink.cmp").setup({
		keymap = {
			preset = "super-tab",
			["<Tab>"] = {
				function(cmp)
					if cmp.snippet_active() then
						return cmp.accept()
					else
						return cmp.select_and_accept()
					end
				end,
				"snippet_forward",
				"fallback",
			},
			["<C-d>"] = {
				"select_next",
				"fallback",
			},
			["<C-u>"] = {
				"select_prev",
				"fallback",
			},
			["<C-j>"] = {
				"scroll_documentation_down",
				"fallback",
			},
			["<C-k>"] = {
				"scroll_documentation_up",
				"fallback",
			},
			["<A-1>"] = {
				function(cmp)
					cmp.accept({ index = 1 })
				end,
			},
			["<A-2>"] = {
				function(cmp)
					cmp.accept({ index = 2 })
				end,
			},
			["<A-3>"] = {
				function(cmp)
					cmp.accept({ index = 3 })
				end,
			},
			["<A-4>"] = {
				function(cmp)
					cmp.accept({ index = 4 })
				end,
			},
			["<A-5>"] = {
				function(cmp)
					cmp.accept({ index = 5 })
				end,
			},
			["<A-6>"] = {
				function(cmp)
					cmp.accept({ index = 6 })
				end,
			},
			["<A-7>"] = {
				function(cmp)
					cmp.accept({ index = 7 })
				end,
			},
			["<A-8>"] = {
				function(cmp)
					cmp.accept({ index = 8 })
				end,
			},
			["<A-9>"] = {
				function(cmp)
					cmp.accept({ index = 9 })
				end,
			},
			["<A-0>"] = {
				function(cmp)
					cmp.accept({ index = 10 })
				end,
			},
		},
		completion = {
			menu = {
				draw = {
					columns = {
						{ "item_idx" },
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
						{ "source_name" },
					},
					components = {
						kind_icon = {
							text = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
									if dev_icon then
										return dev_icon
									end
								elseif vim.tbl_contains({ "Copilot" }, ctx.source_name) then
									return ctx.kind_icon
								end
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							highlight = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
									if dev_icon then
										return dev_hl
									end
								elseif vim.tbl_contains({ "Copilot" }, ctx.source_name) then
									return ctx.kind_hl
								end
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							highlight = function(ctx)
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
									if dev_icon then
										return dev_hl
									end
								end
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						label = {
							text = function(ctx)
								local hl_info = require("colorful-menu").blink_highlights(ctx)
								if hl_info ~= nil then
									return hl_info.label
								end
								return ctx.label
							end,
							highlight = function(ctx)
								local highlights = {}
								local hl_info = require("colorful-menu").blink_highlights(ctx)
								if hl_info ~= nil then
									highlights = hl_info.highlights
								end
								for _, idx in ipairs(ctx.label_matched_indices) do
									table.insert(highlights, {
										idx,
										idx + 1,
										group = "BlinkCmpLabelMatch",
									})
								end
								return highlights
							end,
						},
						item_idx = {
							text = function(ctx)
								return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
							end,
							highlight = "BlinkCmpItemIdx",
						},
					},
				},
			},
			documentation = {
				auto_show = true,
			},
			ghost_text = {
				enabled = true,
			},
		},
		sources = {
			default = function()
				local success, node = pcall(vim.treesitter.get_node)

				if
					success
					and node
					and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
				then
					return { "buffer" }
				else
					return {
						"conventional_commits",
						"lsp",
						"path",
						"snippets",
						"buffer",
						"ripgrep",
						"lazydev",
						"copilot",
					}
				end
			end,
			per_filetype = {
				["pi-chat-prompt"] = { "pi" },
			},
			providers = {
				buffer = {
					opts = {
						get_bufnrs = function()
							return vim.tbl_filter(function(bufnr)
								return vim.bo[bufnr].buftype == ""
							end, vim.api.nvim_list_bufs())
						end,
					},
				},
				cmdline = {
					enabled = function()
						return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
					end,
				},
				conventional_commits = {
					name = "Conventional Commits",
					module = "blink-cmp-conventional-commits",
					enabled = function()
						return vim.bo.filetype == "gitcommit"
					end,

					---@module "blink-cmp-conventional-commits"
					---@type blink-cmp-conventional-commits.Options
					opts = {},
				},
				copilot = {
					name = "Copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				ripgrep = {
					name = "Ripgrep",
					module = "blink-ripgrep",

					---@module "blink-ripgrep"
					---@type blink-ripgrep.Options
					opts = {
						backend = {
							use = "gitgrep-or-ripgrep",
						},
					},
				},
				path = {
					opts = {
						get_cwd = function(_)
							return vim.fn.getcwd()
						end,
					},
				},
				snippets = {
					should_show_items = function(ctx)
						return ctx.trigger.initial_kind ~= "trigger_character"
					end,
				},
				pi = { name = "Pi", module = "pi.completion.blink" },
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuOpen",
		callback = function()
			vim.b.copilot_suggestion_hidden = true
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpMenuClose",
		callback = function()
			vim.b.copilot_suggestion_hidden = false
		end,
	})
end

return M

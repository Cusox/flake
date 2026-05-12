local M = {}

local gh = function(x)
	return "https://github.com/" .. x
end
local cb = function(x)
	return "https://codeberg.org/" .. x
end

function M.setup()
	-- Dap
	vim.pack.add({
		gh("mfussenegger/nvim-dap"),
	})

	local dap = require("dap")

	dap.adapters["codelldb"] = {
		type = "executable",
		command = "codelldb",
	}

	dap.configurations.c = {
		{
			name = "Launch file",
			type = "codelldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
	}
	dap.configurations.cpp = dap.configurations.c
	dap.configurations.rust = dap.configurations.c

	for _, group in pairs({
		"DapBreakpoint",
		"DapBreakpointCondition",
		"DapBreakpointRejected",
		"DapLogPoint",
	}) do
		vim.fn.sign_define(group, { text = "●", texthl = group })
	end
	vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "debugPC", numhl = "debugPC" })

	dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

	vim.keymap.set("n", "<leader>ddb", function()
		require("dap").toggle_breakpoint()
	end, { desc = "Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>ddc", function()
		require("dap").continue()
	end, { desc = "Continue" })
	vim.keymap.set("n", "<leader>ddi", function()
		require("dap").step_into()
	end, { desc = "Step Into" })
	vim.keymap.set("n", "<leader>dds", function()
		require("dap").step_over()
	end, { desc = "Step Over" })
	vim.keymap.set("n", "<leader>ddo", function()
		require("dap").step_out()
	end, { desc = "Step Out" })
	vim.keymap.set("n", "<leader>ddr", function()
		require("dap").run_last()
	end, { desc = "Run Last" })
	vim.keymap.set("n", "<leader>ddq", function()
		require("dap").terminate()
	end, { desc = "Terminate" })

	-- Dap View
	vim.pack.add({
		gh("igorlfs/nvim-dap-view"),
		cb("Jorenar/nvim-dap-disasm"),
	})
	require("dap-view").setup({
		winbar = {
			sections = {
				"watches",
				"scopes",
				"exceptions",
				"breakpoints",
				"threads",
				"repl",
				"disassembly",
			},
		},
		windows = {
			size = 0.5,
			position = "right",
			terminal = {
				size = 0.25,
				position = "below",
			},
		},
		virtual_text = {
			enabled = true,
		},
		auto_toggle = true,
		follow_tab = true,
	})
	require("dap-disasm").setup({})
end

return M

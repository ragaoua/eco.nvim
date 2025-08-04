local M = {}

M.setup = function()
	local eco = require("eco")
	vim.keymap.set("n", "<leader>x", eco.run, { desc = "[ECO] Insert commandline output at current cursor position" })
end

--- Execute a shell command and paste its standard output at the current cursor position.
--- The command is executed asynchronously. The "current cursor position" refers to the
--- position at the time the command finishes
---
--- @param cmd string: The shell command to execute
M.execute = function(cmd)
	vim.system({ "sh", "-c", cmd }, {}, function(result)
		if result.code ~= 0 then
			error(string.format("Command '%s' failed with exit code %d :\n%s", cmd, result.code, result.stderr))
			return
		end

		vim.schedule(function()
			vim.api.nvim_paste(result.stdout, false, -1)
		end)
	end)
end

--- Prompts the user for a shell command and executes it.
M.run = function()
	vim.ui.input({
		prompt = "Execute : ",
		completion = "shellcmdline",
	}, function(input)
		if not input or #input == 0 then
			return
		end
		M.execute(input)
	end)
end

return M

-- TODO: display information about a command in progress (spinner, dous...) on the status line
-- TODO: add support for interpreters other than the default shell (?)
-- TODO: write tests

local eco = {}

--- Requires the plugin and sets up default keymaps
eco.setup = function()
	local eco = require("eco")

	vim.keymap.set("n", "<leader>x", function()
		eco.prompt_for_command({ insert_before = true })
	end, { desc = "[ECO] Insert command output before the current cursor position" })

	vim.keymap.set(
		"n",
		"<leader>X",
		eco.prompt_for_command,
		{ desc = "[ECO] Insert command output at the current cursor position" }
	)
end

--- Execute a shell command and paste its standard output at the cursor position.
--- The command is executed asynchronously. The "cursor position" refers to the
--- position at the time the command finishes
---
--- @class EcoOptions
--- @field insert_before? boolean If true, inserts before the current cursor position instead of the at current position
---
--- @param cmd string The shell command to execute
--- @param opts? EcoOptions Options
eco.insert_command_output = function(cmd, opts)
	local shell = os.getenv("SHELL") or "sh"

	vim.system({ shell, "-c", cmd }, {}, function(result)
		if result.code ~= 0 then
			error(string.format("Command '%s' failed with exit code %d :\n%s", cmd, result.code, result.stderr))
			return
		end

		vim.schedule(function()
			opts = opts or {}

			if opts.insert_before then
				local cursor_position = vim.api.nvim_win_get_cursor(0)
				local row, col = cursor_position[1], cursor_position[2]
				vim.api.nvim_win_set_cursor(0, { row, col - 1 })
			end

			vim.api.nvim_paste(result.stdout, false, -1)
		end)
	end)
end

--- Prompts the user for a shell command and passes it to `insert_command_output`.
---
--- @param opts? EcoOptions Options passed to `insert_command_output`.
eco.prompt_for_command = function(opts)
	vim.ui.input({
		prompt = "Execute : ",
		completion = "shellcmdline",
	}, function(input)
		if not input or #input == 0 then
			return
		end
		eco.insert_command_output(input, opts)
	end)
end

return eco

-- TODO: display information about a command in progress (spinner, dots...) on the status line
-- TODO: add support for interpreters other than the default shell (?)
-- TODO: write tests
-- TODO: handle piping
-- TODO: support executing selected command / current line command
-- TODO: do all SHELLs support "-c" ?

local eco = {}

--- Requires the plugin and sets up default keymaps
---
--- @class PluginOptions
--- @field ignore_default_keymaps? boolean If true, do not set default keymaps
---
--- @param opts? PluginOptions
eco.setup = function(opts)
	require("eco")
	opts = opts or {}

	if not opts.ignore_default_keymaps then
		local keymaps = require("eco.keymaps")
		keymaps.setup()
	end
end

--- Execute a shell command and paste its standard output at a given position.
--- The command is executed asynchronously.
---
--- @param shell string shell interpreter for running the command
--- @param cmd string The shell command to execute
--- @param row_idx integer 0-indexed line position at which the output will be inserted
--- @param col_idx integer 0-indexed column position at which the output will be inserted
---
eco._insert_command_output = function(shell, cmd, row_idx, col_idx)
	vim.system({ shell, "-c", cmd }, {}, function(result)
		if result.code ~= 0 then
			error(string.format("Command '%s' failed with exit code %d :\n%s", cmd, result.code, result.stderr))
			return
		end

		local lines = vim.split(result.stdout, "\n", { plain = true })
		vim.schedule(function()
			vim.api.nvim_buf_set_text(0, row_idx, col_idx, row_idx, col_idx, lines)
		end)
	end)
end

--- Prompt the user for a shell command, execute it and insert the output after the current cursor position.
--- The command is executed by the user's shell (identified by the `SHELL` env variable). If unset, use `sh`.
---
--- @class CmdOptions
--- @field insert_before? boolean If true, inserts before the current cursor position instead of the at current position
---
--- @param opts? CmdOptions Options
eco._prompt_for_command = function(opts)
	local shell = os.getenv("SHELL") or "sh"

	vim.ui.input({
		prompt = shell .. "> ",
		completion = "shellcmdline",
	}, function(input)
		if not input or #input == 0 then
			return
		end

		local cursor_position = vim.api.nvim_win_get_cursor(0)

		-- vim.api.nvim_win_get_cursor(...)[1] is the 1-indexed cursor row position
		local row_idx = cursor_position[1] - 1
		-- Insert after cursor by default (stays consistent with the way vim pastes text using `p` in normal mode).
		local col_idx = cursor_position[2] + 1

		opts = opts or {}
		if opts.insert_before and col_idx > 0 then
			col_idx = col_idx - 1
		end

		eco._insert_command_output(shell, input, row_idx, col_idx)
	end)
end

return eco

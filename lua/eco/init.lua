-- TODO: display information about a command in progress (spinner, dous...) on the status line
-- TODO: add support for interpreters other than the default shell (?)
-- TODO: write tests

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

--- Execute a shell command and paste its standard output at the cursor position.
--- The command is executed asynchronously. The "cursor position" refers to the
--- position at the time the command finishes
---
--- @class CmdOptions
--- @field insert_before? boolean If true, inserts before the current cursor position instead of the at current position
---
--- @param cmd string The shell command to execute
--- @param opts? CmdOptions Options
eco._insert_command_output = function(cmd, opts)
	local shell = os.getenv("SHELL") or "sh"

	vim.system({ shell, "-c", cmd }, {}, function(result)
		if result.code ~= 0 then
			error(string.format("Command '%s' failed with exit code %d :\n%s", cmd, result.code, result.stderr))
			return
		end

		vim.schedule(function()
			opts = opts or {}

			local cursor_position = vim.api.nvim_win_get_cursor(0)
			-- col = cursor_position[2] + 1 > insert after cursor by default.
			-- This is to stay consistent with the way vim pastes text using `p` in normal mode.
			local row, col = cursor_position[1], cursor_position[2] + 1
			if opts.insert_before then
				if col > 0 then
					col = col - 1
				end
			end

			local lines = vim.split(result.stdout, "\n", { plain = true })
			vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
		end)
	end)
end

--- Prompts the user for a shell command and passes it to `insert_command_output`.
---
--- @param opts? CmdOptions Options passed to `insert_command_output`.
eco._prompt_for_command = function(opts)
	vim.ui.input({
		prompt = "Execute : ",
		completion = "shellcmdline",
	}, function(input)
		if not input or #input == 0 then
			return
		end
		eco._insert_command_output(input, opts)
	end)
end

return eco

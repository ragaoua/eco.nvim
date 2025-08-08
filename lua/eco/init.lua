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

--- Execute a shell command and paste its standard output at the current cursor position.
--- The command is executed asynchronously.
---
--- @param cmd string The shell command to execute
--- @param insert_after boolean If true, insert after cursor. if false, insert before cursor
--- @param shell? string Shell interpreter for running the command. If not provided, use the user's default shell. If not set, use "sh"
---
eco._insert_command_output = function(cmd, insert_after, shell)
	shell = shell or os.getenv("SHELL") or "sh"

	vim.system({ shell, "-c", cmd }, {}, function(result)
		if result.code ~= 0 then
			error(string.format("Command '%s' failed with exit code %d :\n%s", cmd, result.code, result.stderr))
			return
		end

		local lines = vim.split(result.stdout, "\n", { plain = true })
		vim.schedule(function()
			vim.api.nvim_put(lines, "c", insert_after, true)
		end)
	end)
end

--- Prompt the user for a shell command, execute it and insert the output after the current cursor position.
--- The command is executed by the user's shell (identified by the `SHELL` env variable). If unset, use `sh`.
---
--- @param insert_after boolean If true, insert after cursor. if false, insert before cursor
eco._prompt_for_command = function(insert_after)
	local shell = os.getenv("SHELL") or "sh"

	vim.ui.input({
		prompt = shell .. "> ",
		completion = "shellcmdline",
	}, function(input)
		if not input or #input == 0 then
			return
		end

		eco._insert_command_output(input, insert_after, shell)
	end)
end

return eco

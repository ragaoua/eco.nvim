--- Executes a command or prompts the user for one, then inserts its output.
---
--- This function is used internally by the `:Eco` and `:EcoBefore` user commands.
--- If no arguments are provided, it prompts the user to input a shell command.
--- If arguments are provided, it treats those as a single command to be executed.
---
--- @param createUserCmdOpts vim.api.keyset.create_user_command.command_args The options passed from `vim.api.nvim_create_user_command`,
--- @param insert_after boolean If true, insert after cursor. if false, insert before cursor
local prompt_or_execute_command = function(createUserCmdOpts, insert_after)
	local eco = require("eco")
	if #createUserCmdOpts.fargs == 0 then
		eco._prompt_for_command(insert_after)
	else
		eco._insert_command_output(createUserCmdOpts.args, insert_after)
	end
end

vim.api.nvim_create_user_command("Eco", function(opts)
	prompt_or_execute_command(opts, true)
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("EcoBefore", function(opts)
	prompt_or_execute_command(opts, false)
end, {
	nargs = "*",
})

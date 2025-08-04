--- Executes a command or prompts the user for one, then inserts its output.
---
--- This function is used internally by the `:Eco` and `:EcoBefore` user commands.
--- If no arguments are provided, it prompts the user to input a shell command.
--- If arguments are provided, it executes the command directly.
---
--- @param createUserCmdOpts vim.api.keyset.create_user_command.command_args The options passed from `vim.api.nvim_create_user_command`,
--- @param ecoOpts? table Options passed to the `eco` module (e.g., `{ insert_before = true }`)
local prompt_or_execute_command = function(createUserCmdOpts, ecoOpts)
	local eco = require("eco")
	if #createUserCmdOpts.fargs == 0 then
		eco._prompt_for_command(ecoOpts)
	else
		eco._insert_command_output(createUserCmdOpts.args, ecoOpts)
	end
end

vim.api.nvim_create_user_command("Eco", function(opts)
	prompt_or_execute_command(opts)
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("EcoBefore", function(opts)
	prompt_or_execute_command(opts, { insert_before = true })
end, {
	nargs = "*",
})

vim.keymap.set(
	"n",
	"<leader>X",
	":EcoBefore<CR>",
	{ desc = "[ECO] Insert command output before the current cursor position" }
)

vim.keymap.set("n", "<leader>x", ":Eco<CR>", { desc = "[ECO] Insert command output at the current cursor position" })

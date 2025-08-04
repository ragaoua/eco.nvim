-- TODO: comment this function
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

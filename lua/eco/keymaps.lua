local keymaps = {}

keymaps.setup = function()
	vim.keymap.set(
		"n",
		"<leader>X",
		":EcoAppend<CR>",
		{ desc = "[ECO] Insert command output after the current cursor position" }
	)

	vim.keymap.set(
		"n",
		"<leader>x",
		":Eco<CR>",
		{ desc = "[ECO] Insert command output at the current cursor position" }
	)
end

return keymaps

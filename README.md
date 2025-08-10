# eco.nvim

**eco.nvim** is a lightweight Neovim plugin that lets you run shell commands and insert their output directly into your buffer. Ideal for capturing the result of quick shell one-liners without leaving your editor.

Neovim already has similar features via the `:r` command and the `!!` keymap (which maps to the `:.!` command), but they have some shortcomings:
- They only allow you to insert or replace whole lines: `!!` replaces the current line with the output of a command, and `:r` inserts the output on a new line.
  **eco.nvim** operates differently, as it inserts the output onto the current line, either at or after the _cursor_ position. See [Use cases](#use-cases).
- They do not detect error codes or differentiate between stdout and stderr. If the command fails, its error message is inserted just like normal output (which you don't want, usually).
  Instead, **eco.nvim** won't insert anything if the command returns a non-zero exit code, and outputs the error message in the command area.

## Features

- Prompt for a shell command and insert its output at or after the cursor position
- Uses the user's default shell (`$SHELL`)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "ragaoua/eco.nvim" }
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { "ragaoua/eco.nvim" }
```

## Usage

### User commands

The plugin defines the `:Eco` and `:EcoAppend` commands.

`:Eco` prompt for a shell command, executes it and inserts the output at the cursor position.
It is possible to skip the prompting of the shell command by providing it directly to `:Eco`, like so : `:Eco echo "this will be inserted"`.

`:EcoAppend` behaves strictly like `:Eco`, except it inserts the output after the current cursor position the command.

### Default mappings

| Keymap      | Command    |
|-------------|------------|
| `<leader>x` | :Eco       |
| `<leader>X` | :EcoAppend |

note: these defaults are motivated by the way pasting works in vim. `p` pastes text at the cursor position. `P` pastes it before the cursor. Hence, `x` and `X`.

Default mappings can be ignored using the `ignore_default_keymaps` configuration option:

```lua
{
    "ragaoua/eco.nvim",
    opts = {
        ignore_default_keymaps = true,
    },
}
```

## Shell behavior

By default, **eco.nvim** uses the shell defined by the `SHELL` environment variable (e.g. `/bin/bash`, `/bin/zsh`, ...) when executing commands. If `SHELL` is not set, it falls back to `sh`.
Only POSIX-compliant shells are fully supported. Some non-POSIX shells (`fish`, `csh`...) might still work if they implement the `-c` flag (which is used to execute commands), but those aren't guaranteed.


## Use cases

**eco.nvim** is particularly useful when writing documentation (e.g. code tutorials). Below are some examples.

One notable use case is being able to paste system clipboard when no other option is available (via `xclip -o` on Linux or `pbpaste` on macOs).

### Insert content from a file (e.g. log file, config file, script...)

![plugin preview 1](https://i.imgur.com/briuS3w.gif)

### Insert useful command outputs (e.g. directory filetree, system info...)

![plugin preview 2](https://i.imgur.com/0vRrz96.gif)

This can be useful to write bug reports for instance.

### Pretty print json strings

![plugin preview 3](https://i.imgur.com/SiJXuuD.gif)


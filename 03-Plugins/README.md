# 03 - Plugins

## plugin manager

There are a lot of plugin managers out there for both vim and neovim. 2 popular ones are [VimPlug](https://github.com/junegunn/vim-plug) and [Packer](https://github.com/wbthomason/packer.nvim). Since packer is written in lua and was made for neovim, I'm going to use it. You can either install packer manually or through a lua function that gets executed automatically when neovim starts, but only if packer isn't already installed. If you don't want that and only want to install it now, run the following command in your terminal:

```sh
$ git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

Create a file called `plugins.lua` in your `lua` directory with the following code. If you don't want the bootstrap code, you can ignore this section of the guide.

```lua
-- ~/.config/nvim/plugins.lua

local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system {
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/wbthomason/packer.nvim',
		packer_path
	}

	print 'Installing packer...\nclose and reopen neovim after the installation has finished.'

	vim.cmd [[packadd packer.nvim]]
end
```

This will ensure that packer gets installed automatically if it's not already installed. Now we want to setup packer to install some plugins. We need to import packer first; and the best way to do that is to use a [protected call](https://www.lua.org/manual/5.1/manual.html#pdf-pcall). A protected call takes in 2 or more arguments:

1. a function to execute
2. the arguments to that function

It will also return 2 values. The first value will be a boolean determining whether the call was successful or not, and the return value of the function inside the protected call.

One way to import packer would be:

```lua
local packer = require 'packer'
```

But this will crash if packer isn't installed or if it's broken. The safe way to import packer would be the following:

```lua
local packer_ok, packer = pcall(require, 'packer')
```

This will return a `packer_ok` variable that we can check so we don't try to execute code that could potentially fail. The final setup should look something like this:

```lua
-- ~/.config/nvim/plugins.lua

local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system {
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/wbthomason/packer.nvim',
		packer_path
	}

	print 'Installing packer...\nclose and reopen neovim after the installation has finished.'

	vim.cmd [[packadd packer.nvim]]
end

local packer_ok, packer = pcall(require, 'packer')
if packer_ok then

	packer.startup(function(use)

		-- packer is a plugin itself, so it can update itself
		use { 'wbthomason/packer.nvim' }

		--[[
		... all your other plugins go here
		]]

		if PACKER_BOOTSTRAP then
			packer.sync()
		end

	end)

end
```

The `use` keyword is a function that takes in either a string or a table. If you provide a string, it will interpret it as part of a GitHub URL. If you provide a table, it will take the first element in the table and interpret it as a GitHub URL; everything after that it will take as optional arguments. For example, if you want to install the [catppuccin](https://github.com/catppuccin/nvim) theme, your code could look like this:

```lua
local packer_ok, packer = pcall(require, 'packer')
if packer_ok then

	packer.startup(function(use)

		-- packer is a plugin itself, so it can update itself
		use { 'wbthomason/packer.nvim' }

		-- the best theme ever
		use { 'catppuccin/nvim', as = 'catppuccin' }

		if PACKER_BOOTSTRAP then
			packer.sync()
		end

	end)

end
```

Because the repo's name is "nvim", and we don't want a folder called "nvim" in our plugin directory, we tell packer to rename the repo to "catppuccin", which is the name of the theme. If packer is installed, you can run `:PackerSync` inside of neovim and it will sync your installed plugins with the list that you provided. Note that this only _installs_ the plugins, it won't configure them! You need to do that yourself. For example, in order to configure our theme, we can create a file called `theme.lua` in our `after/plugin` directory:

```lua
-- ~/.config/nvim/after/plugin/theme.lua

local catppuccin_ok, catppuccin = pcall(require, 'catppuccin')
if catppuccin_ok then

	vim.g.catppuccin_flavour = 'mocha'
	catppuccin.setup {}

	vim.cmd [[colorscheme catppuccin]]

end
```

`vim.g.catppuccin_flavour` is a theme-specific variable that sets the variant of the theme. `catppuccin.setup {}` is the setup function for catppuccin which we don't pass any arguments to for now. `vim.cmd` is a function that lets you embed vimscript into lua. We do that here to apply the colorscheme; as far as I'm aware there is no way of doing that in lua right now, but feel free to correct me here! Since this file is in the `after/plugin` directory, we don't need to manually `require` it. If you open neovim now, you should be greeted by a much nicer colorscheme. I'm gonna throw my current config for catppuccin in here, if you want something to start with:

```lua
local catppuccin_ok, catppuccin = pcall(require, 'catppuccin')
if catppuccin_ok then
	vim.g.catppuccin_flavour = 'mocha'
	local colors = require('catppuccin.palettes').get_palette()

	catppuccin.setup {
		transparent_background = true,
		term_colors = true,
		styles = {
			comments = { 'italic' },
			conditionals = { 'italic' },
			functions = { 'italic' },
			types = { 'bold' }
		},
		integration = {
			treesitter = true,
			native_lsp = {
				enabled = true,
				virtual_text = {
					errors = { 'italic' },
					hints = { 'italic' },
					warnings = { 'italic' },
					information = { 'italic' },
				}
			},
			telescope = true,
			nvimtree = {
				enabled = true,
				show_root = true,
				transparent_panel = true
			}
		},
		custom_highlights = {
			WinSeparator = { bg = colors.none }
		}
	}

	vim.cmd [[colorscheme catppuccin]]
end
```

A lot of lua plugins follow this pattern. You're going to see the

```lua
local name_of_plugin = require 'name_of_plugin'

name_of_plugin.setup {}
```

...schema quite a lot if you use plugins written in lua. The [next part of the guide](../04-LSP-Treesitter/README.md) will focus on [Treesitter](https://tree-sitter.github.io/tree-sitter/) and [LSP](https://microsoft.github.io/language-server-protocol/), 2 very important technologies when it comes to a nice development experience.

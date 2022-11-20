# 02 - Options

## configuring neovim

Neovim has a lot of options that you can change. You can always read the documentation for a specific options with `:help <option>` or `:help options` to read about options in general. An easy way to organize your settings is to create a dedicated file for it. For example, if you want to enable a number column on the left side of the screen to see which line you're on, you can do something like this:

```lua
-- ~/.config/nvim/lua/options.lua

vim.opt.number = true
```

This works perfectly fine and is equivalent to `set number` in vimscript. But since lua is a proper programming language, and because you probably have a lot of options you want to change, we can do this in a more elegant way:

```lua
-- ~/.config/nvim/lua/options.lua

local options = {
	-- ... your options here
}

for name, value in pairs(options) do
	vim.opt[name] = value
end
```

This will loop over **key, value** pairs in the 'options' [table](https://www.tutorialspoint.com/lua/lua_tables.htm) and then set the options accordingly. It's no different from writing `vim.opt.` 30 times but it looks way better in my opinion. I'm going to apply some options here without explaining what they do, but remember: you can always read about them with `:help`.

```lua
-- ~/.config/nvim/lua/options.lua

local options = {
	-- meta settings
	backup = false,
	belloff = 'all',
	bufhidden = 'wipe',
	cdhome = true,
	clipboard = 'unnamedplus',
	confirm = true,
	errorbells = false,
	fileencoding = 'utf-8',
	icon = true,
	mousehide = true,
	swapfile = false,
	undodir = '/home/max/.config/nvim/undo',
	undofile = true,
	updatetime = 50,
	verbose = 0,
	visualbell = false,

	-- indentation
	autoindent = true,
	breakindent = true,
	copyindent = true,
	expandtab = false,
	preserveindent = true,
	smartindent = true,
	smarttab = true,
	shiftwidth = 2,
	tabstop = 2,

	-- visuals
	background = 'dark',
	cmdheight = 1,
	cursorcolumn = false,
	cursorline = true,
	guicursor = 'a:block,i:ver50,v:hor50,r:hor50',
	guifont = 'JetBrains Mono:h16',
	helpheight = 8,
	list = false,
	listchars = {
		tab = '» ',
		space = '·',
	},
	menuitems = 8,
	number = true,
	pumheight = 8,
	relativenumber = true,
	scrolloff = 8,
	showmode = false,
	sidescroll = 1,
	sidescrolloff = 8,
	signcolumn = 'yes',
	splitbelow = true,
	splitright = true,
	syntax = 'ON',
	termguicolors = true,
	wrap = true,
	wrapmargin = 8,

	-- search settings
	hlsearch = false,
	incsearch = true,
	ignorecase = true
}

for name, value in pairs(options) do
	vim.opt[name] = value
end
```

Also remember to put `require 'options'` in your `init.lua` to apply those options.

The next thing you might want to do is set custom keymaps. Neovim provides a nice lua API to set custom keymaps with `vim.keymap.set`. You can define a keymap by calling the `vim.keymap.set` function and passing in some arguments. The first argument will be the mode in which you want the keymap to apply. You can pass an empty string here if you want to apply the keymap to every mode. The second argument will be a string containing the key sequence that you want to press to activate the keymap. The third argument is the action that you want to be executed when hitting the key sequence. The fourth argument is a table of options for that keymap. An example keymap could look like this:

```lua
-- ~/.config/nvim/lua/keymaps.lua

vim.keymap.set('n', '<C-h>', ':echo "hello world"<cr>', {})

```

1. 'n' - "normal" mode
2. '\<C-h\>' - ctrl+h
3. ':echo ...' - output a message at the bottom of the screen
4. '\<cr\>' - carriage return aka. "enter"; you need this because neovim will basically just type whatever you put in this string, so you need to tell it to hit "enter" as well
5. {} - empty table; we don't want to pass any options to this keymap

If you now put `require 'keymaps'` in your `init.lua`, it should load them properly. Again there is a more elegant way to organize this. We can create a variable for `vim.keymap.set` so that we don't have to write it over and over again. We can also create an `options` variable to store default options that we want to pass to most/all keymaps. If you have used vim before, you are probably familiar with the concept of a "leader" key. It's a special key you can set and then use for your keymaps. This way you won't have to change 100 lines of code anytime you change your leader key. In this example I'm going to set <Space> as my leader key like so:

```lua
-- ~/.config/nvim/lua/keymaps.lua

local map = vim.keymap.set
local o = { silent = true }

map('', '<Space>', '<Nop>', o) -- unbind space
vim.g.mapleader = ' ' -- set space as leader key

map('n', 'U', '<C-R>', o)
map('n', '<C-s>', '<cmd>w<CR>', o)
map('n', 'x', '"_x', o) -- delete without yanking
map('n', 'yw', 'yiw', o) -- yank a word from anywhere
map('n', 'dw', '"_diw', o) -- delete a word from anywhere without yanking
map('n', 'cw', '"_ciw', o) -- change a word from anywhere without yanking
map('n', 'cc', '"_cc', o) -- change line without yanking
map('v', 'c', '"_c', o) -- change selection without yanking
map('v', 'p', '"_dP', o) -- override selected word without yanking it
map('x', 'p', '"_dP', o)
map('n', 'ss', '<cmd>split<CR>', o)
map('n', 'sv', '<cmd>vsplit<CR>', o)
map('n', '<leader>r', '<cmd>%s/', {})

-- line navigation / movement
map('n', 'j', 'gj', o)
map('n', 'k', 'gk', o)
map('n', 'J', 'V:m \'>+1<CR>gv=gv<ESC>', o)
map('n', 'K', 'V:m \'<-2<CR>gv=gv<ESC>', o)
map('v', 'J', ':m \'>+1<CR>gv=gv', o)
map('v', 'K', ':m \'<-2<CR>gv=gv', o)
map('x', 'J', ':m \'>+1<CR>gv=gv', o)
map('x', 'K', ':m \'<-2<CR>gv=gv', o)
map('n', '>', '>>', o)
map('n', '<', '<<', o)
map('x', '>', '>gv', o)
map('x', '<', '<gv', o)

-- buffer / window navigation
map('n', '<C-h>', '<C-w>h', o)
map('n', '<C-j>', '<C-w>j', o)
map('n', '<C-k>', '<C-w>k', o)
map('n', '<C-l>', '<C-w>l', o)
map('n', '<S-h>', '<cmd>bprevious<CR>', o)
map('n', '<S-l>', '<cmd>bnext<CR>', o)
map('n', '<C-w>', '<cmd>bdelete<CR>', o)
map('t', '<S-h>', '<cmd>bprevious<CR>', o)
map('t', '<S-l>', '<cmd>bnext<CR>', o)
```

These are keymaps that I like to use, but you dont need to copy them 1:1. I do want to mention a few things here though:

1. \<cmd\> - this is basically the same as `:` except that it will work in any mode
2. 'x' and 't' - 'x' stands for "visual block mode" which is accessed by pressing shift+v. 't' stands for "terminal mode" (yes, neovim has a built in terminal!)
3. { silent = true } - this will ensure that the keymap doesn't print anything at the bottom of the screen; you can apply that as you wish

You can now set your favorite keymaps and move on to the next [part of the guide](../03-Plugins/README.md).

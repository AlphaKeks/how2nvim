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

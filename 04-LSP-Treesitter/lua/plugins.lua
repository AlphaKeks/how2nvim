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

		-- the best theme ever
		use { 'catppuccin/nvim', as = 'catppuccin' }

		-- API to interact with treesitter
		use { 'nvim-treesitter/nvim-treesitter', commit = 'cd9dfc1e48e8ad27b75cf883ba036e83b7079b9a' }
		use { 'windwp/nvim-autopairs', commit = '5fe24419e7a7ec536d78d60be1515b018ab41b15' }

		-- API to interact with LSP
		use { 'neovim/nvim-lspconfig', commit = '1fcd44ef5f5ada6b2d9b29001aa91e352f9b6c76' }

		-- completion engine
		use { 'hrsh7th/nvim-cmp', commit = '913eb8599816b0b71fe959693080917d8063b26a' }

		use { 'hrsh7th/cmp-nvim-lsp', commit = 'affe808a5c56b71630f17aa7c38e15c59fd648a8' }
		use { 'hrsh7th/cmp-nvim-lsp-signature-help', commit = '3dd40097196bdffe5f868d5dddcc0aa146ae41eb' }
		use { 'hrsh7th/cmp-path', commit = '447c87cdd6e6d6a1d2488b1d43108bfa217f56e1' }

		if PACKER_BOOTSTRAP then
			packer.sync()
		end

	end)    

end

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

                if PACKER_BOOTSTRAP then
                        packer.sync()
                end
    
        end)    
    
end

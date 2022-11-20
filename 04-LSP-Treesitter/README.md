# 04 - LSP and Treesitter

## Treesitter
"Tree-sitter is a parser generator tool and an incremental parsing library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited."

Simply put: treesitter will parse your code and build a syntax tree that other plugins can use to understand the structure of your code. Other editors such as vim or VSCode use [regex](https://en.wikipedia.org/wiki/Regular_expression) to give syntax highlighting for example. Neovim is able to use treesitter instead which generally results in more correct and complex syntax highlighting while also being much faster. There is a lot to it, so if you're interested you can read the documentation. The important thing to understand however is, that treesitter has nothing to do with [LSP](https://microsoft.github.io/language-server-protocol/).

## LSP
"The idea behind the *Language Server Protocol (LSP)* is to standardize the protocol for how such servers and development tools communicate. This way, a single *Language Server* can be re-used in multiple development tools, which in turn can support multiple languages with minimal effort."

Simply put: LSP is a *protocol* that enables your editor to communicate with a *language server*. A language server will parse your code and can give you diagnostics, autocompletion, code actions, formatting... and your editor needs to be able to understand those instructions. LSP is a standardized way of implementing this across different editors and IDEs.

## using Treesitter
While treesitter is built-in for neovim, it's pretty difficult to work with out of the box. That's why there's a plugin that acts as an API to communicate with treesitter more easily. First, install the plugin:

```lua
--[[ ... ]]

packer.startup(function(use)
		-- API to interact with treesitter
		use { 'nvim-treesitter/nvim-treesitter', commit = 'cd9dfc1e48e8ad27b75cf883ba036e83b7079b9a' }
end)

--[[ ... ]]
```

Now create a config file for treesitter:

```lua
-- ~/.config/nvim/after/plugin/treesitter.lua

local ts_ok, ts = pcall(require, 'nvim-treesitter.configs')
if ts_ok then
	ts.setup {
		ensure_installed = 'all',
		ignore_install = { '' },
		highlight = { enable = true },
		autopairs = { enable = true },
		indent = { enable = true }
	}
end
```

This configuration will tell treesitter to install the parsers for every supported language, as well as to manage syntax highlighting and indentation. The `autopairs` section sadly doesn't provide autopairs, but it tells treesitter to provide information that other plugins can use to autocomplete characters such as `'`, `"`, `(`, ...

If you've done everything correctly, treesitter should start compiling the parsers the next time you open up neovim. Now you should have fancy syntax highlighting an better auto-indentation for your code!

In order to get autopairs working we can install a plugin that will use treesitter to provide autopairs.

```lua
--[[ ... ]]

packer.startup(function(use)
		-- autopairs
		use { 'windwp/nvim-autopairs', commit = '5fe24419e7a7ec536d78d60be1515b018ab41b15' }

end)

--[[ ... ]]
```

Because it's not a lot of code, we can add the setup function for `nvim-autopairs` to our treesitter file:

```lua
-- ~/.config/nvim/after/plugin/treesitter.lua

--[[ ... ]]

local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then
	autopairs.setup { check_ts = true, disable_filetypes = { 'TelescopePrompt', 'vim' } }
end
```

Now you should have autopairs support as well.

## using LSP
LSP is built-in as well, but it's a similar situation as with treesitter. It is recommended to install the [lspconfig](https://github.com/neovim/nvim-lspconfig) plugin to interact with neovim's LSP. 

```lua
--[[ ... ]]

packer.startup(function(use)
		-- API to interact with LSP
		use { 'neovim/nvim-lspconfig', commit = '1fcd44ef5f5ada6b2d9b29001aa91e352f9b6c76' }

end)

--[[ ... ]]
```

Now create a config file for LSP:

```lua
-- ~/.config/nvim/after/plugin/lsp.lua

local lsp_ok, lsp = pcall(require, 'lspconfig')
if lsp_ok then

	local on_attach = function(client, bufnr)
		if client.supports_method('textDocument/formatting') then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.formatting_sync()
				end
			})
		end
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	vim.fn.sign_define('DiagnosticSignError', { texthl = 'DiagnosticSignError', text = '', numhl = '' })
	vim.fn.sign_define('DiagnosticSignWarn', { texthl = 'DiagnosticSignWarn', text = '', numhl = '' })
	vim.fn.sign_define('DiagnosticSignHint', { texthl = 'DiagnosticSignHint', text = '', numhl = '' })
	vim.fn.sign_define('DiagnosticSignInfo', { texthl = 'DiagnosticSignInfo', text = '', numhl = '' })

	vim.diagnostic.config {
		virtual_text = true,
		signs = { active = signs },
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = 'minimal',
			source = 'always',
			header = '',
			prefix = '',
			border = 'rounded'
		},
	}

	vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
	vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

	-- servers
	lsp['tsserver'].setup {
		on_attach = on_attach,
		capabilities = capabilities
	}

end
```

There is a lot to process here, so let's go through the file step by step.

```lua
local on_attch = ...
```

This is a function that you can name whatever you want, I like to call it `on_attach` because that's the name LSP uses as well. In this function you can execute whatever code you want to execute whenever a language server *attaches* to a buffer; meaning: whenever you open a file that triggers one of your servers. In this example I'm checking if code formatting is currently supported; if it is, I'm creating an autocmd that will automatically format my code when I save a file. Note that this will only work if your language server supports formatting! It's also important to understand that this is only a function declaration, it doesn't do anything yet.

```lua
local capabilities = vim.lsp.protocol.make_client_capabilities()
```

Next, we declare our *client's* capabilities. This basically just tells a language server what our *client* - neovim - is capable of doing.

```lua
vim.fn.sign_define('DiagnosticSignError', { texthl = 'DiagnosticSignError', text = '', numhl = '' })
vim.fn.sign_define('DiagnosticSignWarn', { texthl = 'DiagnosticSignWarn', text = '', numhl = '' })
vim.fn.sign_define('DiagnosticSignHint', { texthl = 'DiagnosticSignHint', text = '', numhl = '' })
vim.fn.sign_define('DiagnosticSignInfo', { texthl = 'DiagnosticSignInfo', text = '', numhl = '' })

vim.diagnostic.config {
	virtual_text = true,
	signs = { active = signs },
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = true,
		style = 'minimal',
		source = 'always',
		header = '',
		prefix = '',
		border = 'rounded'
	},
}

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
```

These are simply UI changes that make prompts look a bit nicer, technically you don't need them, but I like to see fancy icons and rounded borders. Note that you need a patched font to see those icons, so make sure to use a [NerdFont](https://www.nerdfonts.com/) of your choice for your terminal.

```lua
-- servers
lsp['tsserver'].setup {
	on_attach = on_attach,
	capabilities = capabilities
}
```

Now we can setup some language servers. In this example I'm setting up the `typescript-language-server`. You can view the full list of supported servers [here](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) as well as some example code for each server. Keep in mind that we are only *configuring* the `tsserver` here. You need to have it on your system and in your [PATH](https://en.wikipedia.org/wiki/PATH_(variable)) to be functional. Most language servers are installed through [npm](https://www.npmjs.com/), but not all of them. The [list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) mentioned above also contains links to all language servers so you can find out how to install them. I'm using NodeJS version 18.9.0 and run the following command to install the Typescript language server:

```sh
# npm i -g typescript-language-server
```

You can also install it in some separate directory and add it to your [PATH](https://en.wikipedia.org/wiki/PATH_(variable)).

Now that you have installed a language server, and configured it with `lspconfig`, you should get diagnostics for your code. You can check which servers are currently running via `:LspInfo`. To make full use of the language server you probably want to set some keymaps as well.

```lua
-- ~/.config/nvim/lua/keymaps.lua

--[[ ... ]]

-- lsp
map('n', '<leader><leader>', '<cmd>lua vim.lsp.buf.hover()<CR>', o)
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', o)
map('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', o)
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', o)
map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', o)
map('n', 'gL', function()
	vim.diagnostic.goto_next()
	vim.diagnostic.open_float()
end, o)
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', o)
map('n', 'gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', o)
map('n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', o)
map('i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', o)
```

Most of keymaps should be self-explainatory, but I do want to mention some things here. As you can see, the third argument of our `map` function can also be a literal function instead of a string! That's the beatuy of lua and it's really useful if you need to execute multiple function calls. If you only want to call one function however, it's easier to just call `:lua` to execute a function (or \<cmd\>lua in this case). If you want to read documentation about any of those functions, you can run `:help vim.lsp.buf.` and let autocompletion do its thing.

## nvim-cmp
Speaking of autocompletion... neovim (as of writing this) doesn't have a nice way to provide autocompletion! There is a plugin that we can use called `nvim-cmp`.

```lua
--[[ ... ]]

packer.startup(function(use)
		-- completion engine
		use { 'hrsh7th/nvim-cmp', commit = '913eb8599816b0b71fe959693080917d8063b26a' }

end)

--[[ ... ]]
```

`nvim-cmp` is a completion *engine* which means it provides completion support for neovim. You could compare it to LSP in a sense, because it still needs completion *sources* that provide the actual completion via `nvim-cmp` to neovim. [This guy]() wrote a lot of completion-source plugins so I reccommend you go ahead and check out his repositories. I personally really like the following 3:

1. LSP completion - `use { 'hrsh7th/cmp-nvim-lsp', commit = 'affe808a5c56b71630f17aa7c38e15c59fd648a8' }`

2. LSP completion when entering function arguments - `use { 'hrsh7th/cmp-nvim-lsp-signature-help', commit = '3dd40097196bdffe5f868d5dddcc0aa146ae41eb' }`

3. file system completion - `use { 'hrsh7th/cmp-path', commit = '447c87cdd6e6d6a1d2488b1d43108bfa217f56e1' }`

The good thing is, you don't need to manually setup each source. The bad thing is, the setup function for `nvim-cmp` is quite long, but we can get through this, I promise!

```lua
-- ~/.config/nvim/after/plugin/cmp.lua

local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then

	menu_icons = {
		Text = '',
		Method = '',
		Function = '',
		Constructor = '',
		Field = 'ﰠ',
		Variable = '',
		Class = 'ﴯ',
		Interface = '',
		Module = '',
		Property = 'ﰠ',
		Unit = '塞',
		Value = '',
		Enum = '',
		Keyword = '',
		Snippet = '',
		Color = '',
		File = '',
		Reference = '',
		Folder = '',
		EnumMember = '',
		Constant = '',
		Struct = 'פּ',
		Event = '',
		Operator = '',
		TypeParameter = ''
	}

	cmp.setup {
		mapping = cmp.mapping.preset.insert {
			['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
			['<CR>'] = cmp.mapping.confirm({ select = true }),
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { 'i', 's' }),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { 'i', 's' })
		},
		formatting = {
			format = function(_entry, vim_item)
				vim_item.kind = (menu_icons[vim_item.kind] or '')
				return vim_item
			end
		},
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'nvim_lsp_signature_help' },
			{ name = 'path' }
		},
		confirm_opts = {
			behavior = cmp.ConfirmBehavior.Replace,
			select = false
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		}
	}
end
```

We start by defining some icons for the completion menu (if you don't have a [NerdFont](https://www.nerdfonts.com/) installed, you won't be able to see them). We then setup some mappings for navigating the completion menu and applying the icons. After that we define the *sources* for `nvim-cmp` to use. Since we only have 3 installed, we only specify those 3. We then also set rounded corners for everything so that it matches our LSP UI setup. If everything worked, you should now have a nice completion menu with fancy icons when you're writing code!

If you followed the whole guide you should now have a nice basic setup and understanding of how to configure and extend neovim. If you want some ideas for plugins you can use, you can check out [this list](https://github.com/stars/AlphaKeks/lists/neovim) that I made with plugins that I use(d), or you can check out other people's dotfiles. If you have any suggestions for this repo, I'd appreciate the feedback!

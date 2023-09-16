# Setting up LSP support

> If you haven't read [Why (neo)vim? - The vim philosophy](./why-vim.md) and don't know what LSP is
yet, I suggest you give it a read. It's the last section in that file.

Although LSP support is "builtin" it might not feel as "builtin" when coming from other editors.
What neovim means by "builtin" is: neovim knows how to talk to language servers; it can make
requests and interpret the responses. That's about it. neovim does not and will never ship with
language servers pre-installed. This is _your_ job. For example, Rust's language server is called
[rust-analyzer](https://rust-analyzer.github.io) and it's your job to install it. There are many
language servers out there for many languages and neovim cannot be expected to ship their binaries.
To install rust-analyzer simply run `rustup component add rust-analyzer` in your terminal and you
should be good to go. Depending on the language server the installation process is going to be
different, so I won't cover anything else here. RTFM and figure out how to install it!

Assuming you now have your language server installed, in your `$PATH` and executable, we can and
tell neovim about it. Create a file in `after/ftplugin` for your language, for example
`after/ftplugin/rust.lua` and use `vim.lsp.start` to start a language server whenever you enter
a file of that filetype:

```lua
vim.lsp.start({
  name = "rust-analyzer",
  cmd = { "rustup", "run", "stable", "rust-analyzer" },
  root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true })[1]),
})
```

> I took this example straight from `:help LSP`, btw. It's the go-to help page for this topic!
> Be sure to read `:help vim.lsp.start` and `:help vim.lsp.start_client` for all the options you can
> use here.

Now, when you open up neovim in a Rust project setup with cargo, you should get diagnostics for any
errors after waiting for a few seconds. rust-analyzer in particular has a pretty slow startup time,
so just wait a bit. Other servers like `tsserver` for TypeScript are faster on startup; this will
differ from server to server.

But other than diagnostics, you don't really have a lot to go off of, right? How do you jump to
a variable's definition? How do you look up references? How do you rename a variable? All those
questions and more are answered by `:help LSP`. The module you want to look at here is
`vim.lsp.buf`. It contains all of those features and more! `vim.lsp.buf.definition` will jump to the
definition of the symbol below your cursor. `vim.lsp.buf.references` will put all references to the
symbol below your cursor into the quickfix list. `vim.lsp.buf.rename` will prompt you for a new name
for the symbol below your cursor and change all the instances to the new name you provide.

> Reminder: you can run all of these functions with `:lua`. This makes experimenting pretty easy!

But typing all of that out everytime is cumbersome. Let's define some keymaps!

```lua
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gR", vim.lsp.buf.rename)
```

But we don't want these keymaps to apply for any buffers that don't have an LSP server attached to
them. `gd` for example is a default mapping that we are overriding here, so we would probably want
to keep its default functionality whenever we are not using LSP. How do we solve this? The answer is
our good old friend the autocommand:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufmap = function(modes, lhs, rhs)
      return vim.keymap.set(modes, lhs, rhs, { buffer = event.buf })
    end

    bufmap("n", "gd", vim.lsp.buf.definition)
    bufmap("n", "gr", vim.lsp.buf.references)
    bufmap("n", "gR", vim.lsp.buf.rename)
  end,
})
```

> Make sure to define this somewhere in your config _outside_ of `after/` so that it loads early
> enough.

`LspAttach` is an event that fires anytime any language server attaches to a buffer. Inside the
callback of this event we define a small wrapper function around `vim.keymap.set` that makes
defining buffer-local keymaps shorter. Then we define all the keymaps we want just like before, but
using our new helper.

Now, whenever a language server is running we can use our keymaps to perform tasks you probably
solved by right clicking and selecting an option from a menu before. Some other important functions
that you should create some mappings for are `vim.lsp.buf.hover` and `vim.lsp.buf.code_action`. Try
them out to see what they do!

# Troubleshooting

If you don't notice the language server attaching, something might have gone wrong. To debug this
neovim creates a log file for LSP servers to dump messages into. This log file can be opened by
typing `:edit ` and pressing `<C-r>=`, then typing `stdpath('state') . '/lsp.log'` and hitting
enter. It should expand to something like `/home/alphakeks/.local/state/nvim/lsp.log`. If you don't
find any useful errors in that log file, you should double check your setup and make sure all the
arguments are correct. If you can't find anything wrong with it, have a look at
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig). It's a plugin that provides preset
configurations for a ton of different language servers. I will go over how to use it in the next
section, but even if you don't use it, it's a good resource to look at for specific server
configurations to steal for your own setup.

# [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

The main job of this plugin is to reduce

```lua
vim.lsp.start({
  name = "rust-analyzer",
  cmd = { "rustup", "run", "stable", "rust-analyzer" },
  root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true })[1]),
})
```

to

```lua
require("lspconfig").rust_analyzer.setup({})
```

It also provides useful commands such as `:LspInfo` and `:LspLog` which are useful for debugging.
The `setup` function you call for each language server takes the same arguments as `vim.lsp.start`
and will override any of its default values with the ones provided by you. It's really just a thin
wrapper around `vim.lsp.start` with sane defaults so that you don't have to figure out the exact
settings for every server you use.
[This document](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
has a list of all the supported language servers, with links to their respective websites and a list
of default values set by `nvim-lspconfig`. Any of the settings you see on that page are
_defaults_. You don't need to specify them yourself.

If you want to use a language server that is not in that list, you will have to fall back to using
`vim.lsp.start` yourself and figure out the correct settings. Most popular servers are part of
`nvim-lspconfig` though.

# Other LSP related plugins

`nvim-lspconfig` in my opinion is all you really need, but there are lots of other plugins that
provide language specific support, extensions, or just general LSP utilities that a lot of people
like.

## [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

`nvim-cmp` is often used together with LSP, although it's not tied to it. It's a general purpose
completion engine that provides a generic interface for completion _sources_. This includes LSP, but
also snippets, buffer words, the filesystem, git commit hashes, or anything else you could think of.
This means that in addition to `nvim-cmp` itself you also need to install each source you want as an
individual plugin. For example, to get LSP completion you need
[cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). You will also need a snippet engine like
[LuaSnip](https://github.com/L3MON4D3/LuaSnip).

To understand how insert completion is handled in neovim by default, read `:help ins-completion`.
It's really interesting and I recommend you give it a thorough read! None of that is
**auto**completion though, which is what most people want. After reading it, you should know what
omnicompletion is and what the `omnifunc` option does. neovim ships with an omnifunc for LSP that
you can set in your `LspAttach` autocommand from earlier:

```lua
vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
```

Now you can use `<C-x><C-o>` to ask for LSP completions in insert mode. It's very "manual" and also
doesn't look as pretty as `nvim-cmp`. I'm autistic enough to write my own `omnifunc`, but anyone
else should probably just use `nvim-cmp`. It's very configurable and has a lot of examples in their
README and Wiki on GitHub.

## [mason.nvim](https://github.com/williamboman/mason.nvim)

`mason.nvim` is a plugin used for installing common tools that you might want to use with
neovim. This includes language servers, but also standalone formatters, linters and debuggers. It's
important to note here that mason does nothing else. It only installs programs. It will put them in
`mason/bin` inside of `stdpath('data')`.

> A note on rust-analyzer: you should _always_ install rust-analyzer using `rustup`. No exceptions.
> The version mason will give you is a standalone version decoupled from cargo and is known to cause
> many issues, just don't use it. 99.9% of things you can install with mason should work perfectly
> fine though.

## [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)

This plugin is meant to bridge the gap between `mason.nvim` and `nvim-lspconfig` to completely
automate both the installation and configuration of language servers. I personally see no point in
this as you will pretty much always want to change _some_ of the defaults. The only valuable thing
this plugin provides in my opinion is the `ensure_installed` option in the plugin's `setup`
function. It lets you list all the LSP servers you want to install automatically if they're not
already installed. I honestly don't know why this isn't just part of `mason.nvim` but if you want
that, you have to use `mason-lspconfig.nvim`, I guess. Take a look at the plugin's README on GitHub
for more detailed information.

## [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim), [nvim-lint](https://github.com/mfussenegger/nvim-lint) and [formatter.nvim](https://github.com/mhartington/formatter.nvim)

These plugins are all meant to bridge the gap between \<random external tool\> and neovim's LSP API.
Especially `null-ls` embodied this idea by creating a "fake" language server that can be controlled
using all the normal `vim.lsp` APIs you're used to, but talks to external tools like prettier or
eslint under the hood, using some specific implementation. The plugin is now archived though, and
people have shifted to using alternatives. I personally don't use any of them as I don't see any use
for them. I mainly write rust and `rust-analyzer` + `cargo` do anything I could ever want. If you
work with a more convoluted ecosystem though, like JavaScript or Python, you might find these
plugins useful as they simplify the setup of various formatters and linters.

## [lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim)

This is a controversial one. There's a lot of people who love this plugin, and a lot of people who
hate it. I personally am part of the latter group. VonHeikemen has done an amazing job documenting
this plugin and has acknowledged most of the issues I and many others have with `lsp-zero`. I have
absolutely nothing against him as a person or plugin author.

`lsp-zero`'s main job is reduction of boilerplate. As a result of that, a certain level of
abstraction is basically guaranteed. This makes it not only more difficult to debug issues yourself,
but it also makes it more difficult for other people who don't use `lsp-zero` to help you. From my
experience people end up writing just as much code, if not more, using `lsp-zero` than just using
`nvim-lspconfig` and nothing else. The plugin advertises a just works™ LSP experience which in
reality just isn't the case for everyone. And once shit hits the fan it's really difficult to debug.
I can definitely see the idea behind this plugin but the execution is suboptimal. There's a lot of
custom functions or commands that just wrap existing things for seemingly no reason. This forces you
to do things "the lsp-zero way" and mixing `lsp-zero`'s magic with `nvim-lspconfig` etc. just leads
to confusion.

I think it's much easier and also better for your own understanding to just setup LSP, completion,
etc. yourself, composing the plugins that you actually need and understanding your setup, instead of
just copy pasting code.

To give credit where credit is due, VonHeikemen has written an insane amount of documentation for
`lsp-zero` including sections showing the exact code you would need to write without `lsp-zero` to
replicate its functionality, explaining each step along the way. Unfortunately I don't think most
people actually read those docs though, which is a shame.

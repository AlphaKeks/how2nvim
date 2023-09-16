# Getting to know the editor

There's a few things in both vim and neovim that you should familiarize yourself with. The main
thing here is `:help` as already mentioned in the main README. The most important help page of all
(in my opinion) is `:help user-manual`. It is written like a book, going over all the basic and also
more advanced vim stuff you should know, so go and give it a read! If you don't know vim motions
yet, type `vimtutor` in your terminal. That will open up an interactive "game" in vim that teaches
you all the motions. If you use neovim, you can also run `:Tutor`.

I want to touch on some basics that are also covered in `:help user-manual`, but with a more
up-to-date perspective. The user manual was written for vim and while it doesn't lie, it also
doesn't talk about modern neovim APIs.

> After going through vimtutor and `:help user-manual` you should read `:help :help`. It goes over
> how to navigate the help manual, how to follow links, etc. and will be very useful in the future.
> Since I will be referring to the help manual quite a lot, you should know how to navigate it.

If you have _any questions_ about _anything_, consider looking in `:help` and you might just find
something!

# Table of contents

- [Where to put your configuration](#Where-to-put-your-configuration)
- [Options](#Options)
- [Keymaps](#Keymaps)
- [Structuring your config](#Structuring-your-config)

## Where to put your configuration

neovim will expect an `init.vim` or `init.lua` file in a specific directory. Where that directory is
depends on your operating system, but by default:

- Linux / MacOS: `~/.config/nvim`
- Windows: `~/AppData/Local`

These follow the [XDG base directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).
To start configuring, create that directory if it doesn't exist already and create an `init.vim` or
`init.lua` inside of it (whichever you prefer). In the following sections I will give code examples
for both vimscript and Lua, which you can put in that file.

## Colorschemes (or "themes")

The default colorscheme vim and neovim ship with looks quite disgusting. Luckily there are other
builtin colorschemes as well that look less hideous. A good one is `habamax`. To change your
colorscheme put this in your config:

```vim
" vimscript

colorscheme habamax
```

```lua
-- Lua

vim.cmd.colorscheme("habamax")
```

How to override specific colors will be covered later in [Structuring your config](#Structuring-your-config).

## Options

Options, or settings, whatever you want to call them, are the most basic way of configuring neovim.
A quick look at `:help option-list` shows that there are _a lot_ of these, and they are all
documented. By running `:help '<option>'` you get access to a detailed explanation of the given
option, along with possible values for that option and how it may interact with other options.
Generally there are 5 types of options: booleans, numbers, strings, lists and dictionaries.

A boolean option can be enabled by running `:set <option>` and disabled by prefixing the option's
name with a `no`. For example, to enable / disable line numbers you can run:

```vim
" vimscript

" enabling line numbers
set number

" disabling line numbers
set nonumber
```

```lua
-- Lua

-- enabling line numbers
vim.opt.number = true

-- disabling line numbers
vim.opt.number = false
```

Numbers and strings follow the `set <option>=<value>` format. For example, the `tabstop` option
controls how wide a tab character (`\t`) should be. To make tabs as wide as 4 spaces you would run:

```vim
" vimscript

set tabstop=4
```

```lua
-- Lua

vim.opt.tabstop = 4
```

The `signcolumn` option controls an extra column on the left of your screen which is reserved for
"signs"; these are special symbols that can indicate the git status of a line, diagnostics, or other
things, depending on what you put there. By default this column will be hidden and only show up when
necessary, which shifts the editor to the right whenever a sign appears. I find this very
distracting, so I enable it always:

```vim
" vimscript

set signcolumn=yes
```

```lua
-- Lua

vim.opt.signcolumn = "yes"
```

The `wildoptions` option controls how the completion in command mode, i.e. `:` works. If you take
a look at `:help 'wildoptions'` you can see that there are multiple values, multiple of which can
be combined. I personally have it configured like this:

```vim
" vimscript

set wildoptions=fuzzy,pum
```

```lua
-- Lua

-- using a string
vim.opt.wildoptions = "fuzzy,pum"

-- using a table
vim.opt.wildoptions = { "fuzzy", "pum" }
```

The `listchars` option controls which characters get shown when `list` is enabled. For example, to
have a special character for tabs and spaces, you can set `listchars` as follows:

```vim
" vimscript

set listchars=tab:>\ ,space:-
```

```lua
-- Lua

-- using a string
vim.opt.listchars = "tab:> ,space:-"

-- using a table
vim.opt.listchars = {
  tab = "> ",
  space = "-",
}
```

All of these are just examples, of course. You will have to figure out for yourself which options
you care about and which values you want to set them to. Looking at other people's configurations
can be a good way of discovering new options. The other way is reading / searching through
`:help options` to find what you need.

> Another thing I want to mention here is `:options`. It will give you an interactive window that
> lets you change options on the fly and see the changes in real time. This is not necessarily the
> best for _all_ options, but for most it should be pretty useful.

## Keymaps

Keymaps are how you define custom "keybindings" (as other editors call them). The main concept to
understand here is that a "keymap" is literally a _mapping_ from one sequence of keys to another
sequence of keys. You define a "left-hand side" ("lhs") and a "right-hand side" ("rhs"), where the
"lhs" is the keys you want to press, and the "rhs" is the keys you want it to be replaced with.
Another important concept is the "leader key". Think of it like a special variable that you can use
in your mappings. By default the leader key is mapped to `\`. Many people prefer the space key or
`,` though.

How to define your leader key:

```vim
" vimscript

" space
let g:mapleader = ' '

" comma
let g:mapleader = ','
```

```lua
-- Lua

-- space
vim.g.mapleader = " "

-- comma
vim.g.mapleader = ","
```

> A note on the leader key: you need to make sure to define it before any mappings that use it! When
> neovim parses your keymaps it will replace any occurrences of `<Leader>` with whatever value the
> leader key has at that point of execution. Defining it early in your config (or at least before
> any mappings) is a good idea.

### Defining some basic mappings

neovim has a file explorer called `netrw`. You can read about it in `:help netrw`.

To define a mapping for opening it using your leader key followed by `e`, you can write the
following code:

```vim
" vimscript

nnoremap <Leader>e :Explore<CR>
```

```lua
-- Lua

vim.keymap.set("n", "<Leader>e", ":Explore<CR>")
```

Okay, lots of new words! Let's go through them.

- `nnoremap`:
    - `n`: normal mode
    - `nore`: "not recursive"
    - `map`: mapping

- lhs:
    - `<Leader>`: your leader key
    - `e`: the `e` key

- rhs:
    - `:Explore`: the same as typing out that text
    - `<CR>`: special notation for the "enter" key

The mapping we just defined is a non-recursive, normal-mode mapping that presses the keys
`:Explore<Enter>` when we press our leader key followed by `e`. What "non-recursive" means here is
whether any keys in the rhs of this mapping should use the default functionality or existing custom
mappings. Usually you don't want recursive mappings as they can cause unexpected results.

The Lua code I think is easier to understand.

- `vim.keymap`: a Lua module holding everything you need to manage keymaps
- `set`: a function to define a keymap

- The first argument into `vim.keymap.set` is the mode (or mode**s**) you want to apply this mapping
to. It's the equivalent of the first character in the vimscript version.
- The second argument is a string of keys describing the lhs of this mapping.
- The third argument can be multiple things. Either it's a string, in which case it fills the same
  role as the third argument in the vimscript version. Or it can be a callback function, which will
  be called when the lhs is pressed.

`vim.keymap.set` also has a fourth argument, which is a table of options. To read about these, see
`:help vim.keymap.set`. The defaults are sane and you usually don't need to change them. Mappings
are non-recursive by default. To make a mapping recursive pass `{ remap = true }` as the fourth
argument.

And with that you defined your very first mapping! Now you can open the file explorer with just
2 keys anytime you want.

> As a small bonus: anything you can type in command mode (i.e. after pressing `:`) you can also
> access via `vim.cmd` inside of Lua. `vim.cmd` as a function takes a string, which can be any valid
> vimscript, and it will be executed. `vim.cmd` also acts as a module though, which holds functions
> for any commands you would normally run in command mode. So our netrw mapping could also be
> expressed as `vim.keymap.set("n", "<Leader>e", vim.cmd.Explore)` where `vim.cmd.Explore` is
> a function. Note that we don't call the function though! We pass the function itself as a value.

To give an example of a custom lua function as well for the sake of completeness:

```lua
-- Lua

vim.keymap.set("n", "<Leader>hw", function()
  print("Hello, world!")
end)
```

Now, when you press your leader key followed by `h` and `w`, you should get a little message in the
bottom left of your screen!

## Structuring your config

Similar to your [`$PATH`](https://en.wikipedia.org/wiki/PATH_(variable)), neovim also has a set of
directories it will look at for configuration files. These directories are called "runtime
directories", making up the "runtime path". `:help 'runtimepath'` has some more detailed information
on the default value of this option and what each subdirectory does. I will highlight the most
important ones and how you should use them for your own config.

> If you read this out of order and already have a plugin manager
> ([lazy.nvim](https://github.com/folke/lazy.nvim) in particular), then some of the things I will
> cover here will not apply in the same way, as lazy changes the runtimepath quite a bit.

### The `plugin/` directory

This is generally where plugins have their "entry point". Any vimscript or Lua file in this
directory will be executed automatically on startup.

> Note that this isn't the `plugin/` directory in your own config, but rather in each separate
> plugin. Since the `runtimepath` is made up of a list of directories, each plugin you install gets
> its own directory in the `runtimepath` and therefore has the same general structure as your
> config.

### The `colors/` directory

This directory is used to define colorschemes. It's useful when you want to define your own
colorscheme, either to extend an existing one or to write your own.

To define a custom colorscheme simply create a `.vim` or `.lua` with your colorscheme's name as the
filename: `touch ~/.config/nvim/colors/balls.vim`

In that file you can run any code you wish, although you should constrain it to colorscheme-related
code. To "extend" an existing colorscheme, simply call `colorscheme habamax` at the top and then
override any highlight groups you don't like.

Some help pages that might be useful:

- `:help :highlight`
- `:help highlight-groups`
- `:help nvim_set_hl`

For example, to make the editor background pitch black you can have the following code in
`colors/balls.vim` or `colors/balls.lua`:

```vim
" vimscript

colorscheme habamax

highlight! Normal guibg=#000000
```

```lua
-- Lua

vim.cmd.colorscheme("habamax")

vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
```

If you want to make it transparent, use `"NONE"` as the color instead. For more info about this
refer to the help pages mentioned earlier.

### The `after/` directory

`after/` is a special directory that can contain any of the other directories. For example, you can
have a `plugin/` directory, as well as a `after/plugin/` directory. The difference here is the
loading order of the two. Anything in `after/` loads much later than the other directories. This is
useful for configuring plugins, as any files in `after/plugin/` will only run _after_ normal
`plugin/` files already executed.

### `ftplugin/` and `after/ftplugin/`

These directories are used for running filetype-specific code. This is useful for overriding
specific options such as tab-size (`:help 'tabstop'`) or defining custom commands.

For example, to use tabs instead of spaces in rust files, you would create `after/ftplugin/rust.vim`
and put the following code in it:

```vim
" vimscript

setlocal noexpandtab
```

> `setlocal` will change the option only for the current buffer instead of globally.

```lua
-- Lua

vim.bo.expandtab = false
```

> `vim.bo` refers to "buffer option". It has the same effect as using `setlocal` in vimscript.

### Custom directories

The directory names mentioned in `:help 'runtimepath'` are reserved, but you can create any other
files or subdirectories you want as well. How you do this will differ in vimscript vs. Lua, so
I will cover both.

#### Custom directories in vimscript

You can generally put your files wherever you want; some people like to create a `vimrc.d` directory
at the top-level of their config. Some people like to create a directory with their name. This is
really up to you.

As for executing those files, you have 2 options:

- `source` (see `:help :source`)
- `runtime` (see `:help :runtime`)

These are two vimscript commands that will execute vimscript files! The `source` command will
execute any vimscript file you point it to. For example, if you create a `vimrc.d` directory with
a file called `hello.vim` inside of it, you could execute it by putting

```vim
" vimscript

source ~/.config/nvim/vimrc.d/hello.vim
```

in your `init.vim`. This becomes annoying quickly though, so there's a better option: `runtime!`

The `runtime` command (or `runtime!` which we will be using) will take a path relative to your
`runtimepath` and can run multiple files using a glob expression. So to execute _all_ the files in
your `vimrc.d` directory you would put

```vim
" vimscript

runtime! vimrc.d/*.vim
```

in your `init.vim`.

This is the gist of it. As long as you make sure to not use the reserved directories incorrectly,
anything goes! I personally have a directory structure like this:

```
vim
├── after
│   └── ftplugin
│       ├── javascript.vim
│       ├── lua.vim
│       ├── qf.vim
│       ├── rust.vim
│       ├── sql.vim
│       ├── typescript.vim
│       └── vim.vim
├── alphakeks
│   ├── grep.vim
│   ├── keymaps.vim
│   ├── options.vim
│   └── term.vim
├── autoload
│   ├── alphakeks.vim
│   ├── javascript.vim
│   └── rust.vim
├── colors
│   └── dawn.vim
└── vimrc
```

You don't have to structure your config like this, it's just meant as an inspiration.

#### Custom directories in Lua

Lua has a concept of modules which neovim uses extensively in the builtin runtime files. The way
neovim's Lua runtime is configured, it will look for modules in the `lua/` directory in any
`runtimepath` directory. To define a module create `lua/balls.lua` and put some code inside of it:

```lua
-- Lua

print("Hello, world!")
```

Now you can `require` a module in your `init.lua`:

```lua
-- Lua

require("balls")
```

Modules can also be nested using directories. If you have `lua/balls/foo.lua` and
`lua/balls/bar.lua` you can load them individually using `require("balls.foo")` and
`require("balls.bar)` respectively. The name of `init.lua` is special as it counts as the "root" of
a given module. Therefore `balls.lua` and `balls/init.lua` are equivalent.

I personally have a `lua/alphakeks` directory with submodules like this:

```
nvim
├── after
│   ├── ftplugin
│   │   ├── javascript.lua
│   │   ├── javascript.vim
│   │   ├── lua.lua
│   │   ├── qf.lua
│   │   ├── rust.lua
│   │   ├── rust.vim
│   │   ├── sh.vim
│   │   ├── sql.lua
│   │   ├── typescript.lua
│   │   ├── typescript.vim
│   │   └── vim.lua
│   └── plugin
│       ├── comment.lua
│       ├── diagnostics.lua
│       ├── fugitive.vim
│       ├── oil.lua
│       ├── statusline.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       └── winbar.lua
├── autoload
│   └── alphakeks.vim
├── colors
│   └── dawn.lua
├── init.vim
└── lua
    └── alphakeks
        ├── completion.lua
        ├── globals.lua
        ├── init.lua
        ├── lsp
        │   ├── capabilities.lua
        │   └── init.lua
        └── tools
            ├── eslint.lua
            ├── prettier.lua
            └── tsserver.lua
```

This is not how you _have_ to structure your own config, but it's a sane default in my opinion.

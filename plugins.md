# How to install plugins

Plugins in vim and neovim are usually just collections of `.vim` (and in neovim's case `.lua`) files
which can be loaded or interacted with from your own config once you downloaded them. They are
usually managed with [git](https://en.wikipedia.org/wiki/Git) and cloned to your machine when you
install them.

There is a history of plugin managers in vim and neovim going back almost a decade, but nowadays the
neovim community seems to have settled on [lazy.nvim](https://github.com/folke/lazy.nvim). Now,
before you go and install it, I want to present you with other options, as well as my opinion on
each one, and how plugins are "actually" implemented by these plugin managers.

## Popular plugin managers

- [vim-plug](https://github.com/junegunn/vim-plug): probably the most popular plugin manager for
  vim. It's the oldest one of these 3 and was originally made for vim, so everything is vimscript.
  This makes it a bit awkward to use from Lua, but it's a perfectly fine choice and does its job
  well.
- [packer.nvim](https://github.com/wbthomason/packer.nvim): the first Lua only plugin manager for
  neovim. It was the first "neovim only" plugin manager to emerge since neovim started really
  embracing Lua and is pretty much a finished project. When visiting the repo you will notice that
  it is archived, because the maintainer has chosen to stop maintaining it. This does not mean it's
  broken or anything, you just won't get updates anymore. It's a well established plugin manager and
  works exactly as advertised.
- [lazy.nvim](https://github.com/folke/lazy.nvim): the current "standard" the community has settled
  on, with heavy focus on lazy loading. With the rise of Lua, plugins became more and more popular.
  Especially complicated and feature-packed plugins. It's not rare to find a neovim user with 100+
  plugins installed, and if you are one of those users your startup times will be atrocious.
  lazy.nvim tries to solve this by compiling Lua modules to bytecode, lazy loading as much as
  possible and giving you control over exactly when plugins should load.

All 3 work perfectly fine and are acceptable choices, although you might find some people
(especially on reddit) which will for no reason try to convince you to use whatever they're using.

> ⚠️ personal opinion alert ⚠️

lazy.nvim is **not** a very good choice for beginners. It's a complicated behemoth of a plugin
manager packed with complexity that is probably way too overkill for you. It's documentation, while
extensive, does not really explain a lot of things, and it has a lot of features that most users
will probably never need.

The entire focus on lazy loading only became so prevelant because people started using so many
plugins. Especially in the beginning you should keep your plugin count low and only install what you
need, so you don't slow down your editor for no reason, or even worse, break it with an update.

If you actually need the features and complexity lazy.nvim provides, you are probably not a beginner
anymore and can make this decision yourself. If you are new though, lazy.nvim is probably definitely
overkill for you.

## How to install and use each one

### [vim-plug](https://github.com/junegunn/vim-plug)

To install vim-plug, you must clone it onto your machine first:

```sh
$ curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then you can list plugins in your `init.lua`:

```lua
local plug_begin = vim.fn["plug#begin"]
local plug_end = vim.fn["plug#end"]
local Plug = vim.cmd.Plug

plug_begin()

Plug("catppuccin/nvim", { as = "catppuccin" })
Plug("neovim/nvim-lspconfig")
-- ... more plugins

plug_end()
```

And then you use the various `:Plug*` commands to install and update your plugins. Refer to
`:help plug` for details.

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

Install packer by cloning it onto your system:

```sh
$ git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/packer/start/packer.nvim"
```

You can then list your plugins in your `init.lua`:

```lua
require("packer").startup(function(use)
  use("catppuccin/nvim", { as = "catppuccin" })
  use("neovim/nvim-lspconfig")
end)
```

And then you can use `:Packer*` commands to install and upate your plugins. Refer to `:help packer`
for details.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Start by cloning lazy onto your system:

```sh
$ git clone --depth 1 https://github.com/folke/lazy.nvim \
    "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
```

To list plugins you want installed there are multiple ways. The first way is very similar to
vim-plug and packer:

```lua
-- This is necessary for lazy to load
vim.opt.runtimepath:prepend("lazy")

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },

  { "neovim/nvim-lspconfig" },
})
```

The first argument to `setup` can be either a string or a table. In this case we pass it a table
which acts as an array of "plugin specs". A "plugin spec" is a table that describes a plugin you
want to install. The first element in a spec table is the URL of the plugin and any following
arguments are key-value pairs representing options. You can find details about the plugin spec
[here](https://github.com/folke/lazy.nvim#-plugin-spec).

Actually, this array table will accept either plugin specs or strings (or both!) and will treat
strings like the first argument into a spec (i.e. a URL). This means, we could write it also like
this:

```lua
vim.opt.runtimepath:prepend("lazy")

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },

  "neovim/nvim-lspconfig", -- notice that this is not a table anymore!
})
```

The second way of managing plugins is to use a dedicated directory. Instead of passing a list of
plugin specs into `.setup()` you can simply give it the name of a Lua module, which lazy will use as
a source of plugin specs. For example, if you want to keep all your plugins in `lua/plugins/`, you
can call `.setup()` like this:

```lua
vim.opt.runtimepath:prepend("lazy")

require("lazy").setup("plugins")
```

Lazy will now `require` each file in that directory and expect a plugin spec to be returned from it.
So to express your previous config in this way, we would have to create two files:

- `lua/plugins/catppuccin.lua`
- `lua/plugins/lspconfig.lua`

It does not matter how you name these files. All that matters is that **every** file in the
`lua/plugins/` directory must return a valid plugin spec.

```lua
-- lua/plugins/catppuccin.lua

return {
  "catppuccin/nvim",

  name = "catppuccin",
}
```

```lua
-- lua/plugins/lspconfig.lua

return {
  "neovim/nvim-lspconfig",
}
```

The most important plugin spec option is probably `config`. It is a function that will run as soon
as the plugin loads. This ensures that your config code will never run before a plugin actually
loads; this used to be a common issue with older plugin managers because people were accessing
plugin code before their plugins actually loaded.

For example, to install [catppuccin](https://github.com/catppuccin/nvim) and set it as our
colorscheme as soon as it's loaded we can write the following code:

```lua
-- lua/plugins/catppuccin.lua

return {
  "catppuccin/nvim",

  name = "catppuccin",

  config = function()
    require("catppuccin").setup({
      -- ... any config, if you need it
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
```

This neatly encapsulates plugin configs into their own respective files and prevents loading issues.
That is as long as they are all independent of each other. If multiple plugins need to work together
you have to use the `dependencies` key and more carefully design your specs.

Since this plugin manager is all about lazy loading, there are a ton of options you can specify to
make the plugin load only when needed. You can make it load on specific events, pressed keys,
usercommands, or even entirely custom logic.

## How plugin managers work under the hood

To understand how neovim plugins are loaded we first need to understand the `runtimepath`. Similar
to your [`$PATH`](https://en.wikipedia.org/wiki/PATH_(variable)) environment variable it is a list
of directories that neovim will consider to use when searching for specific files. There are a bunch
of special directories that can exist in each `runtimepath` directory. The main ones are the
following:

- `plugin/` any files in this directory will be executed automatically at startup
- `lua/` any Lua files in this directory (and any sub-directories) will be available as Lua modules

There are bunch of these, and you can see a list of them under `:help 'runtimepath'`.

Plugin managers can do two things:

- use existing `runtimepath` directories + `:help packages`
- make their own directory and add it to the `runtimepath`

### neovim's `packages` feature

`packer.nvim` for example uses the first strategy. In fact, it utilizes neovim's `packages` feature.
A "package" contains two directories: `start/` and `opt/`. Each of these can contain as many
directories as you want, each of which will be considered like a directory in your `runtimepath`.
This might sound a bit confusing, so let me give you an example.

Consider the following directory structure:

```
nvim/
└── pack/
    └── mypackage/
        ├── opt/
        │   └── telescope.nvim/
        └── start/
            └── catppuccin/
```

`nvim` is your config directory. Each package under `pack/` can contain plugins which either load on
**start**up, or are **opt**ional. `packer.nvim` for example will create a directory under
`~/.local/share/nvim/site/pack/packer`. Inside of this directory there are `opt/` and `start/`, each
of which can contain plugins you install. Each plugin can then have a `plugin/` directory, a `lua/`
directory, an `after/` directory, and so on.

Every plugin essentially has the same structure as your config, just without an `init.lua` (or
`init.vim`). Plugins in the `opt/` directories will not be loaded automatically and have to be
loaded using the `:packadd` command.

This means that in the example above `catppuccin` will always be loaded on startup, while
`telescope.nvim` will **not**. You have to load it explicitly with `:packadd`.

This is how "lazy loading" works the "vim way".

### lazy.nvim

`lazy.nvim` goes the other direction and just creates its own directory under
`~/.local/share/nvim/lazy`. You add it to your `runtimepath` somewhere in your config and it will
handle the rest from there. It stores all plugins in that same `lazy/` directory and handles the
loading of those plugins internally.

### Handrolling your own plugin system

You can definitely use plugins without using a plugin manager. As mentioned previously, you can have
a `pack/` directory in your config and store your plugins inside there. If you keep your neovim
config in a git repository (or have a "dotfiles" repo in general), you can add your plugins as git
submodules and store them in `pack/alphakeks/...` just fine.

I have done this for a while and eventually decided to write
[my own plugin manager](https://github.com/AlphaKeks/balls.nvim) just for fun. In around 300 lines
of Lua I have the basic install, update and sync commands, as well as lazy loading using
`opt/` + autocommands. If you want a simple, minimal setup, that is definitely the way to go.

# Installing Plugins

Installing plugins is one of the first things many new neovim users jump to straight away, which
I think is a mistake. Most of these people install an insane amount of plugins without understanding
any of them or how their editor works out of the box. I highly recommend you work with neovim or
even vim without any plugins for a while and get used to it. It's a great refresher and will show
you how much you are capable of without any training wheels. However I don't think plugins are bad
per se. I use plugins myself as well, but I know the true value of them. I know what they do for me,
how they work and how I would implement them myself. I just don't have the time or motivation to do
it, and someone else has already done it, so why waste that work?

## Plugin managers

There are many plugin managers out there for both vim and neovim that will manage installing,
updating and maybe even configuring plugins. Some good plugin managers for vim include:

- [vim-plug](https://github.com/junegunn/vim-plug)
- [minipac](https://github.com/k-takata/minpac)

Both of these work in neovim as well, but if you want something written in Lua:

- [packer.nvim](https://github.com/wbthomason/packer.nvim) which is now deprecated but still works,
  and should keep working for a long while
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim) which is the spiritual successor to
  `packer.nvim` but not yet stable.
- [lazy.nvim](https://github.com/folke/lazy.nvim) which is the most popular plugin manager right
  now.

All of these work slightly differently, so I will go over some example setups for both `packer.nvim`
and `lazy.nvim` as they are the most used.

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

First you have to install packer itself, which is described in the [Quickstart](https://github.com/wbthomason/packer.nvim#quickstart).
This can also be bootstrapped using some code:

```lua
local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_installed = vim.loop.fs_stat(packer_path)

if not packer_installed then
  vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    packer_path,
  })

  vim.cmd.packadd("packer.nvim")
  print("Installed packer!")
end

local packer = require("packer")

packer.startup(function(use)
  use("wbthomason/packer.nvim")

  -- ... more plugins
end)
```

For documentation on `use`, see packer's README.

Once your plugins are installed you can configure them by creating files in `after/plugin/`, all of
which will be executed automatically after the plugins themselves have already loaded. For example,
to install [catppuccin](https://github.com/catppuccin/nvim) (the second best colorscheme right after
my own!), you would put this into your `packer.startup`:

```lua
packer.startup(function(use)
  use("wbthomason/packer.nvim")

  use({
    "catppuccin/nvim",
    as = "catppuccin",
  })
end)
```

And in `after/plugin/catppuccin.lua`:

```lua
local catppuccin_installed, catppuccin = pcall(require, "catppuccin")

if not catppuccin_installed then
  return
end

catppuccin.setup({
  -- ... see catppuccin's README for details
})

vim.cmd.colorscheme("catppuccin")
```

`pcall` is a wrapper function that sort of acts like a try-catch. The first value it returns is
a boolean indicating whether everything went okay. If this first value is `false` it means an error
occurred. The second value is the result of the function you passed to it. This guard clause will
ensure that neovim won't throw a million errors anything you start it without plugins installed.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

`lazy.nvim` is a very complex plugin manager with a lot of features, especially centered around lazy
loading. There are 2 "main ways" of using lazy, so I will go over each of them, but let's install it
first.

```lua
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_installed = vim.loop.fs_stat(lazy_path)

if not lazy_installed then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazy_path,
  })
end

vim.opt.rtp:prepend(lazypath)
```

#### Using lazy the packer way

The simplest way to use lazy is to just list all the plugins you want in its `setup` function and
then configuring them using `after/plugin`.

```lua
local lazy = require("lazy")

lazy.setup({
  -- ... list of plugins here
})
```

For example, to install [catppuccin](https://github.com/catppuccin/nvim):

```lua
lazy.setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
})
```

And then in `after/plugin/catppuccin.lua`:

```lua
local catppuccin_installed, catppuccin = pcall(require, "catppuccin")

if not catppuccin_installed then
  return
end

catppuccin.setup({
  -- ... see catppuccin's README for details
})

vim.cmd.colorscheme("catppuccin")
```

#### Using lazy with a dedicated directory

This is the most "automated" way of all, it's how I used lazy when I was still using it.

Somewhere in your config:

```lua
local lazy = require("lazy")

lazy.setup("plugins")
```

This tells lazy to load every file in `lua/plugins/`. It will expect every file to return a table
conforming to a specific format, which lazy calls a "plugin spec". You can read about plugin specs
[here](https://github.com/folke/lazy.nvim#-plugin-spec).

To install a colorscheme like [catppuccin](https://github.com/catppuccin/nvim):

```lua
-- lua/plugins/catppuccin.lua

return {
  "catppuccin/nvim",

  name = "catppuccin",

  config = function()
    -- We don't need the `pcall` wrapper here because this function only runs after lazy ensured
    -- that the plugin is already loaded.
    local catppuccin = require("catppuccin")

    catppuccin.setup({
      -- ... see catppuccin's README for details
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
```

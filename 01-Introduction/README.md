# 01 - Introduction

## Installation

If you are on Linux, there are multiple ways of installing neovim but you should only need to worry about 3 of them:

1. your distribution's repositories
2. AppImage
3. Compiling from source

In this guide I'm only going to cover Linux, but you can check out the [official Installation Guide](https://github.com/neovim/neovim/wiki/Installing-Neovim) if you are on a different platform.

As of writing this, the current stable release version is 0.7.3, so that's the version I'm gonna use. Since installing from a repository is pretty straight forward I'm only going to cover how to install it using an **AppImage** and how to compile it from source.

### AppImage

Installing and using neovim with an AppImage is pretty easy. All you need to do is download the _\*.AppImage_ file from neovim's [releases page](https://github.com/neovim/neovim/releases) (make sure you download the correct version!). After downloading it you need to make it executable.

```sh
$ chmod +x /path/to/nvim.appimage
```

Now you need to put it into a folder that is part of your [PATH](<https://en.wikipedia.org/wiki/PATH_(variable)>). After doing that you should be able to run `nvim` in your terminal, no matter where you are in the filesystem.

### compiling from source

In order to install neovim from source you first need to clone the GitHub repository. Find a location in your filesystem where you want to clone it; I'm gonna use `~/.local/src`.

```sh
$ mkdir -p ~/.local/src
$ cd ~/.local/src
```

Now clone the repository.

HTTPS:

```sh
$ git clone https://github.com/neovim/neovim.git ~/.local/src/neovim
```

SSH:

```sh
$ git clone git@github.com:neovim/neovim.git ~/.local/src/neovim
```

Now `cd` into the repository and switch to the 0.7 stable branch:

```sh
$ cd ~/.local/src/neovim
$ git checkout release-0.7
```

Before compiling you should make sure to install the necessary [dependencies](https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites). Since I am on [Artix Linux](https://artixlinux.org), I'm going to install the following packages:

```sh
# pacman -S base-devel cmake unzip ninja tree-sitter curl
```

The next step is to actually build the program. By default the compiler is going to use 1 CPU thread for compilation, which will take a lot longer than it actually needs to. You can use the `-j` flag followed by a number to assign a custom amount of threads to use. I'm gonna use `30` here because I have a 32-thread CPU.

```sh
$ make -j30 CMAKE_BUILD_TYPE=Release
```

After the build has finished you only need to run 1 more command to finish up the installation

```sh
# make install
```

If everything was successful you should now be able to run `nvim` in your terminal from anywhere in the filesystem.

## getting healthy

The first thing you want to do after opening `nvim` for the first time is `:checkhealth`. This will give you a log covering external tools that can be used with neovim. If the log outputs any errors you want to go ahead and fix them. Lots of warnings are to be expected, but if you get a warning for your system's clipboard, you'll want to fix that. If you are using [X11](https://en.wikipedia.org/wiki/X_Window_System) as your display server, you want to install [xclip](https://github.com/astrand/xclip). If you are using [Wayland](<https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)>), you want to install [wl-clipboard](https://github.com/bugaevc/wl-clipboard).

## config file structure

If you are on Linux or MacOS, neovim will look for configuration files in `$XDG_CONFIG_HOME/nvim`, which will be `$HOME/.config/nvim` for most people. If you are on Windows, that directory will usually be located at `%USERPROFILE%\AppData\Local\nvim`. If you are unsure, you can always run `:rtp` inside of neovim to check where it's looking for files. Inside of that directory it will look for an `init.vim` or `init.lua` file to execute first. In this guide I'm going to show how to use [lua](<https://en.wikipedia.org/wiki/Lua_(programming_language)>) for all configuration files.

You can start by creating an `init.lua` file in your config directory

```lua
-- ~/.config/nvim/init.lua

print 'Hello, world'
```

Now you should see 'Hello, world' being printed out when opening neovim. But you can make your config modular by splitting it up into multiple files. Neovim will execute your `init.lua` first, but after that code is done it will look for other `.vim` or `.lua` files in a `after/plugin` directory and source them automatically.

```lua
-- ~/.config/nvim/after/plugin/test.lua

print 'this should be executed automatically!'
```

Neovim should now print 'Hello, world' and then 'this should be executed automatically!' on startup. But you might also want files that only get executed when explicitly telling neovim to do so. The way you do that is by creating a `lua` directory in your config directory and putting either files or subfolders into that `lua` directory.

```lua
-- ~/.config/nvim/lua/test.lua

print 'Hello from the lua directory'
```

This file now needs to be `required` explicitly in order to be executed.

```lua
-- ~/.config/nvim/init.lua

require 'test'

print 'Hello, world'
```

You don't need to specify the `lua` folder here because that's where neovim will look by default. Usually you also won't need to specify the `.lua` extension either, unless you have a folder **and** a file with the same name. If you have a `lua/test/file.lua`, you can require it with `require 'test.file'`. If you only `require 'test'`, it will look for an `init.lua` inside of `lua/test`.

An example file structure could look like the following:

```
.
├── after
│   └── plugin
│       └── test.lua
├── init.lua
└── lua
    └── test
        └── file.lua
```

Now you have a proper file structure and can continue with the next [part of the guide](../02-Options/README.md).

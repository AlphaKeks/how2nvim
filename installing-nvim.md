# How to install neovim

Depending on your operating system this process will be different, so I will cover Linux, Windows,
and MacOS.

- [Linux](#linux)
- [Windows](#windows)
- [MacOS](#macos)

## Linux

There are a few ways of installing neovim on Linux, so I will touch on all the relevant ones.

### Your system's package manager

This is the canonical way of installing software on Linux and I encourage you to use it. However,
considering how fast neovim is moving, many distributions will lag a version or two behind the
latest stable release, or even a few. If you use [Arch Linux](https://archlinux.org/) or
[NixOS](https://nixos.org/), you should have the latest version, but double-checking never hurts. As
of writing this, the latest stable release of neovim is version 0.9.4. You can check the current
stable release [here](https://github.com/neovim/neovim/releases/tag/stable).

If your system's package manager does not have the latest version available, install it with
a different method.

### AppImage

[AppImages](https://appimage.org/) are a packaging format that is supposed to be
distribution-agnostic. This means they should work on any Linux system. There are exceptions to
this, like [NixOS](https://nixos.org/), but on Debian, Ubuntu, Fedora, or any derivatives of these
you should be fine using an AppImage.

It is important that you have version 2 of the fuse library installed on your system. On Debian and
Ubuntu this package is called `libfuse2`. On Fedora it is called `fuse-devel`, **not** `fuse`.
Fedora packages that are **libraries** end in `-devel`. Make sure the package and version are
correct before installing _any_ AppImage.

Other than fuse there are no dependencies though, so you can download the latest version of neovim:

```sh
$ curl -L "https://github.com/neovim/neovim/releases/download/stable/nvim.appimage" -o nvim
```

Then you need to make it executable:

```sh
$ chmod +x nvim
```

And finally, move it into a directory which is part of your
[$PATH](https://en.wikipedia.org/wiki/PATH_(variable)).

```sh
# Pick one of the listed directories
$ echo $PATH

# Move `nvim` into one of them
$ mv nvim /usr/bin/nvim
```

Now you should be able to run `nvim --version` in your terminal and see an output similar to this:

```
NVIM v0.9.2
Build type: Release
LuaJIT 2.1.1693350652
```

### Compiling from source

Compiling neovim is surprisingly easy. You will need a set of
[prerequisites](https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites).
Assuming you have those installed, building neovim is very simple.

Start by cloning neovim into some directory on your system:

```sh
$ mkdir -p ~/.local/src
$ git clone https://github.com/neovim/neovim.git ~/.local/src/neovim
$ cd ~/.local/src/neovim
```

Then, checkout the `stable` branch (or any other `release-*` / `master` branch if you want
a particular version):

```sh
$ git checkout stable
```

Now, you can compile it using `make`:

```sh
$ make CMAKE_BUILD_TYPE=Release
```

And, to put the produced files where they belong:

```sh
$ sudo make install
```

If you come back to this later to update neovim, make sure to run the following commands to clear
out any build artifacts, and pull the latest version of the code.

```sh
$ make distclean
$ git pull origin <branch>
```

For more information see [Building Neovim](https://github.com/neovim/neovim/wiki/Building-Neovim).

### [Flatpak](https://www.flatpak.org/) / [Snap](https://snapcraft.io/)

Due to the isolated nature of Flatpak and Snap, programs will have restricted permissions depending
on your system's configuration. neovim has shown to have some quirks because of this, and especially
the Snap version of it has caused a lot of performance issues for a lot of people. I do not
recommend installing neovim with either, but it exists for these package managers if you really want
it.

## Windows

If you aren't already using a package manger to install most of your software, you really should.
neovim, like a lot of other software is available via package mangers like

- [winget](https://github.com/microsoft/winget-cli)
- [Scoop](https://scoop.sh/)
- [Chocolatey](https://chocolatey.org/)

If you really hate package managers, or cannot install any of them because of company restrictions,
neovim distributes
[an installer](https://github.com/neovim/neovim/releases/download/stable/nvim-win64.msi) as well.

## MacOS

If you don't already use [Homebrew](https://brew.sh/) to install most of your software, you really
should. neovim is available as a package there which you can install. If you don't want to use
Homebrew for whatever reason, you can download
[a tarball](https://github.com/neovim/neovim/releases/download/stable/nvim-macos.tar.gz) distributed
by neovim instead.

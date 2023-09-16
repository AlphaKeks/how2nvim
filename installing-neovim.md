# Installing neovim

In order to start using neovim, you of course have to install it.

There are 2 main "versions" of neovim you want to consider: stable and nightly. The stable release
of neovim gets updated every few months or so and is generally considered the default. The nightly
version updates, as the name implies, every night. That's not actually true, but close enough. What
it actually means is "the latest commit on the master branch". Generally speaking you will have to
compile neovim yourself to get the nightly version, as no package maintainer can be bothered to
update a package daily.

How you actually install neovim depends on your operating system, so jump to the section that
applies to you:

1) [Linux](#Linux)
2) [Windows](#Windows)
3) [MacOS](#MacOS)

## Linux

There are a few ways of installing neovim on Linux. If you use Arch Linux or NixOS, you should be
fine just installing it using your package manager. Both of these distributions should generally
have the latest stable available. Other distributions like Debian, Ubuntu, Fedora, etc. might be one
or more versions behind, so it's not recommended to use your system's package manager. For all of
these it's generally the easiest to use an [AppImage](https://appimage.org).

### AppImages

AppImage is a packaging format that works across distributions and neovim stable releases always
have an AppImage as well. To download it, head to
[the releases tab](https://github.com/neovim/neovim/releases) and download `nvim.appimage` for the
version you want. This works for both nightly and stable (and any other previous release). After
downloading it you need to make it executable and then put it in a location where your shell can
find it. You also need to make sure to have version 2 of `libfuse` installed. This package has
a different name on different distributions, but for Ubuntu it's called `libfuse2`. Find the package
name and install it using your package manager.

A compact example of how to install neovim on Ubuntu:

```sh
sudo apt install libfuse2
curl "https://github.com/neovim/neovim/releases/download/stable/nvim.appimage" -o nvim
chmod +x nvim
sudo mv nvim /usr/bin/nvim
```

After that you should be able to run `nvim --version` in your terminal and see the latest stable (or
nightly) release that you just downloaded. You will have to repeat this process anytime you wish to
update neovim. There are tools out there for managing AppImage updates, but I haven't used any of
them myself, so your mileage may vary.

### Compiling from source

If you want to compile neovim from source instead, that is also pretty easy. The [neovim wiki](https://github.com/neovim/neovim/wiki)
has [a section on compiling from source](https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source)
which you can follow. It's only 2 commands, and the only thing you need to make sure of first is
that you have all the dependencies installed to build neovim. The section I linked to already
mentions this, so I'm not gonna give a detailed example here. Counting the installation of
dependencies it should be 3 commands in total.

### Snap

Snap bad. The [snap packaging format](https://snapcraft.io/store) is known for performance issues
and various other quirks, so especially if you use Ubuntu and are used to using snaps, don't.
[AppImages](#AppImages) are a much better alternative and have never cause any issues for me or
people I know (at least for installing and using neovim).

## Windows

Installing neovim on Windows should be pretty straightforward. If you don't already use a package
manager to install most of your software, I highly recommend you start doing that. A few good
options include:

- [chocolatey](https://chocolatey.org)
- [scoop](https://scoop.sh)
- [winget](https://github.com/microsoft/winget-cli)

Refer to your package manager's instruction on how to install programs. The [neovim wiki](https://github.com/neovim/neovim/wiki/Installing-Neovim#windows)
also has a few examples for these package managers.

The alternative is to download [the neovim installer](https://github.com/neovim/neovim/releases/latest/download/nvim-win64.msi)
which also comes with a GUI.

## MacOS

Since I've never used MacOS, and only know people using MacOS, the best advice I can give here is to
follow the [neovim wiki](https://github.com/neovim/neovim/wiki/Installing-Neovim#homebrew-on-macos-or-linux).
Homebrew should give you the latest version.

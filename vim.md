# Introduction to vim as an editor

If you've never used a terminal-based text editor, vim can be quite intimidating. I want to show you
the basics of using it and explain some terminology I will be using throughout this repository.

> Everything I talk about here applies to neovim in the exact same way, but for simplicity I will
> just refer to both as "vim". Anytime I run the `vim` command in a terminal, just think `nvim`
> instead if you use neovim.

## Opening and closing

You can run vim simply by running it as a command in your terminal:

```sh
$ vim
```

You can pass a file or directory to it as an argument, which will open that file / directory
immediately.

```sh
# Open a file balled `balls.rs`
$ vim balls.rs

# Open a directory called `src`
$ vim src

# Open the current directory
$ vim .
```

You can quit by typing `:q!` and hitting the "enter" key. Alternatively you can also press `ZQ`.

## Modal editing

vim is what is called a "modal" editor. This means that there are multiple **modes** which you can
switch between. I talk about this in detail in [Getting started with vim motions](./vim-motions.md),
but for now all you need to know is that by default you are in **normal mode**. Any key you press
here is associated with some form of command. The most important key right now is `:`. It will put
your cursor in the bottom left of the screen, which means you are now in **command mode**. Here you
can run commands. The most important command is `:help`. It will open a text document explaining the
basics of vim, and I recommend you read through it!

## Notation

Depending on the situation notation will differ slightly, but for the most part I will use the
following:

- `h` => the `h` key on your keyboard
- `H` => shift + `h` (capitalization matters!)
- `CTRL-h` => the "ctrl" key held down, followed by the `h` key
- `CTRL-H` => same thing as above, your terminal cannot differentiate between the two anyway
- `<C-h>` => also same as above
- `<A-h>` => "alt" key held down, followed by the `h` key
- `<BS>` => the "backspace" key
- `<Tab>` => the "tab" key
- `<Esc>` => the "escape" key
- `<Space>` => the "space" key
- `<CR>` => "carriage return" aka. "enter"
- `<Leader>h` => your "leader" key pressed once, followed by the `h` key

> I talk about the leader key in [Getting to know your editor](./getting-to-know-nvim.md) in the
> keymaps section.

For information on notation in help files specifically, see `:help notation`.

## Editor layout

vim is made up of 6 basic UI components.

At the bottom of your screen you will see what's called the "statusline" (see `:help statusline`).

On the left, hidden by default, is the "statuscolumn" (see `:help statuscolumn`). You can show it by
displaying something like line numbers (`:set number`).

At the top, also hidden by default, is the "tabline" (see `:help tabline`). It will show when you
have more than 1 **tab** open, or if you have a custom one that is always displayed.

When pressing `:` a command line will pop up at the bottom (as mentioned previously).

Finally, you have at least 1 **window** which is displaying a **buffer**. Each window can have its
own "winbar", which is a line of text at the top of the window (see `:help winbar`).

## How to use `:help`

If you run `vim` with no arguments, you should see an intro screen. This screen gives you some hints
for first steps, the most important of which is `:help`. Running `:help :help` will show you a help
page on the `:help` command! You should read through just `:help`, it will show you how to navigate
the help docs, follow links, etc. This will be vital, as I will refer to various `:help` documents
throughout this repository. `:help` is probably one of the most extensive pieces of documentation
you will ever read, and you should know how to use it. The most important things to remember are:

- `CTRL-]` will follow the link below your cursor
- `CTRL-o` will jump back
- `CTRL-w` followed by `o` will make the current window fullscreen.

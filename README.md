# how2nvim

This repo is meant as a starting point for people new to (neo)vim, but also as a reference and
learning material, so it is structured in a way that allows you to either read from start to finish
or to jump between topics as you see fit.

If you find any mistakes, anything unclear or have suggestions for examples / more detailed
explanations feel free to open an issue / PR.

To start off you can read [Why (neo)vim? - The vim philosophy](./why-vim.md). It will give you
a perspective of what it's like to work with (neo)vim, why you would want that, and why you maybe
wouldn't want that. Whether you already decided that you want to use (neo)vim or not, you should
give that document a read to truly know what you're getting yourself into, and whether you like the
idea of it.

## Goals

- Teach you about vim's philosophy and the mindset you need to become effective
- Give explanations on (neo)vim concepts that might be hard to grok coming from other editors
- Detailed code examples and explanations for how to structure your config, various plugins, and
  generally how to approach problems

## Non-goals

vim and neovim are very flexible tools that you can customize to a large degree, but they can't
solve every problem. Many people coming from other editors will try to keep their familiar workflow
and mindset going into neovim and will sooner or later hit a wall with that approach. This guide is
not a "how to recreate VSCode in the terminal".

## Some considerations

### The OS you use

I should also mention that this is heavily Linux biased, as I myself use Linux, but everything
I talk about should work on MacOS and Windows as well. Windows might require extra steps for certain
things to work properly, but I will do my best to mention those explicitly and link to helpful
resources; just know that you might have to put in a little bit more effort if you are using
Windows. WSL counts as "Linux" here for the most part, except for some quirks with things like the
system clipboard, but we will get to those.

### Where to find help / documentation

The answer is `:help`.

No, seriously, it's `:help`. It is by far the most thorough piece of documentation I have ever read.
I will admit that it's a bit difficult to find what you're looking for, especially in the beginning,
but there are ways of using it effectively. I recommend you start by reading `:help :help`.

Communities of other people using vim can also be really helpful! I personally am really active on
[ThePrimeagen's Discord server](https://discord.gg/theprimeagen).

Whenever you have a question about (neo)vim itself, refer to `:help`. Whenever you have a question
about a particular plugin, also refer to `:help`! Or their README, whatever is more detailed.

### How you should use this repository

Below you will find a table of contents, which I recommend you read in order start to finish.
However it's also designed in a way that allows you to read them out of order, if you're interested
in a specific topic.

## Table of contents

- [Why (neo)vim? - The vim philosophy](./why-vim.md)
- [Installing neovim](./installing-neovim.md)
- [Getting to know the editor](./getting-to-know-vim.md)
- [`makeprg` and the quickfix list - basic static analysis workflow](./makeprg.md)
- [Setting up LSP support](./setup-lsp.md)
- [Installing Plugins](./installing-plugins.md)

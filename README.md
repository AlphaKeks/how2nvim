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

I should also mention that this is heavily Linux biased, as I myself use Linux, but everything
I talk about should work on MacOS and Windows as well. Windows might require extra steps for certain
things to work properly, but I will do my best to mention those explicitly and link to helpful
resources; just know that you might have to put in a little bit more effort if you are using
Windows. WSL counts as "Linux" here for the most part, except for some quirks with things like the
system clipboard, but we will get to those.

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

## Table of contents

- [Why (neo)vim? - The vim philosophy](./why-vim.md)

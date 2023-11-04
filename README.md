# how2nvim

Hey!

You probably found this repository by asking a question along the lines of "How do I learn neovim?".
I want to set some expectations. The documents in this repository are my attempt at introducing and
explaining (neo)vim concepts as best as I can, recommending certain practices that I personally
consider "good". There are many possible ways of using (neo)vim and none of them are objectively the
best, but I will try to justify any concrete recommendations I give here.

You can use this repository to learn (neo)vim from scratch, as reference material to come back to
later, or simply to look for ideas to add to your own setup. Everything is structured with links and
I try to keep every document self-contained, with references to other sources if there are knowledge
requirements.

If you have any suggestions, ideas, or mistakes to point out, feel free to
[open an issue](https://github.com/AlphaKeks/how2nvim/issues)!

## The goals of this repository

- teach you how to think about and work with vim effectively
- teach you how to interact with vim and integrate it into your workflow
- teach you how to get started if you're completely new
- give you some cool ideas how to script neovim and extend it to fit your needs

## What this repository is **not**

- an attempt to convince you how neovim is the best editor ever and you should leave your favorite
  IDE immediately
- a neovim "distribution" that will give you a 1-click installation with 5 million plugins to
  recreate VSCode in your terminal as close as possible. If you want that, check out one of the
  following:
    - [LunarVim](https://www.lunarvim.org/)
    - [NvChad](https://nvchad.com/)
    - [LazyVim](https://www.lazyvim.org/)
- a "simple starter template". If you want that, check out
  [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## Some general advices

- Read `:help`
- Read `:help :help`
- Read `:help user-manual`
- Read `README.md` files
- Read GitHub Wiki pages of plugins, if they exist
- Ask other people questions, but [don't ask to ask](https://dontasktoask.com)
- When you ask questions, [ask good ones](https://stackoverflow.com/help/how-to-ask)

# Table of Contents

- [Why neovim over vim](./why-nvim.md)
- [How to install neovim](./installing-nvim.md)
- [Introduction to vim as an editor](./vim.md)
- [Getting started with vim motions](./vim-motions.md)
- [Getting to know your editor](./getting-to-know-nvim.md)
- [Finding your way around](./navigation.md)
- [A basic development workflow](./basic-workflow.md)
- [LSP](./lsp.md)
- [How to install plugins](./plugins.md)
- [Insert Completion](./completion.md)
- [Telescope - probably the most useful plugin you will ever use](./telescope.md)
- [oil.nvim - filetrees are overrated](./oil.md)
- [Git workflow](./git.md)
- [Macros](./macros.md)
- [Scripting utilities](./scripting.md)

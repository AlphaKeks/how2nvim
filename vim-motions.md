# Getting started with vim motions

The best way to get started with vim motions is probably the **vim tutor**. It's an interactive game
that walks you through the most important vim motions and it takes ~30 minutes to complete. If you
have **vim** installed, run `vimtutor` in your terminal. If you have **neovim** installed, run
`:Tutor` after opening neovim.

If you want to switch to neovim and don't know the motions yet, I recommend you install a vim plugin
for whatever editor you currently use. Some examples:

- [VSCode extension](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
- [IdeaVim for IntelliJ IDEs](https://plugins.jetbrains.com/plugin/164-ideavim)

## How to think about vim motions

In the beginning vim motions will feel very weird and arbitrary, but there's a system behind them
which you can learn. At this point I'm assuming you already went through vimtutor and know the basic
motions, but I will explain how you should think about them to remember them more easily.

First, some terminology: keys like `w`, `b`, and `e` I will call "motions". Keys like `d` and `y`
I will call "operators". And keys like `i(` or `a"` I will call "text-objects".

Vim motions are compositions of motions, operators, and text-objects. Motions are the only category
here that works on its own. You can press `w` or `b` by themselves and they will do something.
Operators however require you to specify a motion or text-object _after_ the operator. For example,
`dw` will delete a word. `d` is the "delete" operator and `w` is a motion. It will perform
a deletion across the range of the `w` motion. This is the same pattern for all the operators. `yw`
will yank a word, `ci"` will "**c**hange **i**nside double quotes". You don't need to remember all
of the possible combinations, you just need to remember the operators, motions, and text-objects
individually, and understand the pattern that they follow.

You can also prefix any operation with a "count". Pressing `5w` will move 5 words. `d5j` will
perform a deletion that affects the current line, as well as 5 lines down. Generally speaking you
can prefix _any_ normal mode command with a count to repeat it N times. You can however also prefix
motions, even if your command does not start with a motion (e.g. `d5j`). You cannot do this with
text-objects, i.e. `d5a"` will only delete 1 pair of double quotes instead of 5. You also cannot
prefix an operation on a text-object with a count, i.e. `5da"` also will only delete 1 set of
double quotes.

This pretty simple mental model will make vim motions much more logical, and over time, more
intuitive. You will have to get used to it, obviously, but there is a pattern to it and you will
eventually learn it.

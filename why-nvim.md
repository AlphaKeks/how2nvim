# Why neovim over vim

I will list the **most important** reasons why I choose neovim over vim. There are many small things
that are just "nicer" which on their own wouldn't justify switching editor which I will not mention
here.

If none of these apply to you, you can use vim as well. A lot of what I cover in this repository
will apply to vim in exactly the same way. If you want to get the most out of your editor though,
I think neovim is the way to go.

## neovim moves a lot faster than vim.

This can be good or bad depending on the person. I personally like it. New features get introduced
into neovim much quicker than into vim, which means more features faster, but also more breakages
faster. I found that it breaks rarely, and when it does, is usually pretty easy to fix. I like the
features neovim has which vim lacks, so I use neovim.

## "IDE" features in a very vim-like way

neovim has, in particular with the inclusion of LSP support, adopted ideas that back in the day you
would have only found in "IDEs". However, the way LSP is integrated into neovim's core is very
"vimmy". It interacts a lot with existing vim features, encouraging a similar workflow that you
would have in vim, but with more consistent and generally just better results. vim also has lots of
plugins which implement LSP, so it's not a neovim exclusive, but since it's part of neovim core it's
a lot more stable than vim plugins, a lot faster, and generally plays better with other plugins,
because plugin authors know that everyone just uses the LSP implementation from neovim core.

## [Lua](https://luajit.org/luajit.html) as the primary scripting language

neovim made the choice of embedding a Lua interpreter (LuaJIT 2.1 specifically) into the editor,
which allows you to control it entirely using Lua code. The canonical way of scripting vim was and
still is [vimscript](https://en.wikipedia.org/wiki/Vim_(text_editor)#Vim_script). It has a lot of
quirks and flaws that built up over the decades, and with version 9 of vim,
[vim9script](https://vimhelp.org/vim9.txt.html) was born. neovim took a different direction even
before that, by introducing Lua.

I find Lua to be a much better scripting language. It's a beautiful language, easier to write,
faster to execute than the old vimscript and pretty much tied or even faster than vim9script, and
has applications outside of neovim as well, so you might even know it already. A lot of neovim
specific APIs are centered around and only available in Lua. This does not mean that vimscript is
not available; it works just fine like it does in vim8. The two are also interoperable, so you can
pick and choose what you want to do with vimscript, and what you want to do with Lua. I found that
extending and scripting neovim feels a lot better using Lua.

## [Tree-Sitter](https://tree-sitter.github.io/tree-sitter/)

neovim has a Tree-Sitter engine built-in. This means that if you have appropriate Tree-Sitter
parsers installed, it will parse your text into an AST that you can play with. This allows for much
better syntax highlighting, more text-objects, and more motions.

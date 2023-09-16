# Why (neo)vim? - The vim philosophy

## Disclaimer

In this section I'm going to refer to both editors as just "vim" for simplicity's sake. Anything
I talk about here applies to both editors in the exact same way and it does not matter which one you
use.

## A terminal based workflow

vim is by design a terminal based editor. Although [official vim](https://github.com/vim/vim) ships
with a GUI called `gvim`, most people actually use it in a terminal. The way vim is designed
supports this approach a lot, as vim is mainly a **text editor**. You are meant to compose it with
other tools to perform more complex tasks. Common command line utilities such as

- [find](https://www.gnu.org/software/findutils)
- [grep](https://www.gnu.org/software/grep)
- [sed](https://www.gnu.org/software/sed)

and many others either found their origin in [vi](https://en.wikipedia.org/wiki/Vi) or
[ed](https://en.wikipedia.org/wiki/Ed_(text_editor)) which both predate vim. These tools are either
integrated into vim already or work really well in combination with it.

There is [a really good answer to a StackOverflow question](https://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118)
that goes into detail about how vi and later vim evolved from these programs, and I'm not gonna make
any attempts on improving an already amazing explanation. I'm still gonna go into vim motions, of
course, but that post is a really good prelude to understand the history behind vim, and how it is
related to other very foundational CLI tools.

The mindset you should enter when working with vim is that you mainly edit text. Anything else, like
performing static analysis, compiling / running your code, version control, etc. generally happen
outside of vim and are handled by separate tools. All of this _can_ happen inside of vim as well,
but in the end it will happen by talking to these other tools. If you are coming from an IDE you are
probably used to all of this being managed for you. Many IDEs have a "run button" to execute your
code, will give you diagnostics automatically as you type, or have a version control panel to stage
and commit files to git. With vim you are expected to know how each of these work individually,
using the appropriate tools, so you can compose them together in a workflow that fits you the best.
There are plenty of things that are built into vim that I will touch on in later sections that can
give you a similar pipeline, where static analysis, compilation and version control all happen
inside of vim, but you have to keep in mind that they are still managed by separate programs and you
need to understand how these programs work.

If you want to start using vim you should either be comfortable working in a terminal or be willing
to learn how to do so. While there are GUI frontends for neovim, like [neovide](https://neovide.dev)
I personally don't think they are the optimal way of using vim, because you lose out on all the
flexibility and power a terminal gives you. On that note, vim has a builtin terminal emulator that
you can run, so you can still get a similar experience using a GUI, but for reasons that will
hopefully become clearer later I don't think it completely replaces an actual terminal, where vim is
just another program that you can run.

## Why **neo**vim?

[neovim](https://github.com/neovim/neovim) started as a fork of vim and has evolved a lot since it
started out. A lot of the underlying implementation is different nowadays, and neovim has brought
a lot of new ideas into the mix that vim did not implement. vim however also added lots of new
features over the years which neovim did not adopt, so the compatibilty between the two is not as
close as it once was. The core concepts and how the editor works are the same though, so why use
neovim over vim?

For me there are a few reasons:

1) [Lua](#Lua)
2) [Treesitter](#Treesitter)
3) [LSP](#LSP)

### Lua

vim was historically always configured and extended using **vimscript**, which is
a [DSL](https://en.wikipedia.org/wiki/Domain-specific_language) for vim.
neovim is compatible with the version of vimscript pre-vim9. With version 9 of vim a new version of
vimscript called "vim9script" was introduced, which is a complete rewrite of the vim language that
fixes a lot of the issues that vimscript has. This includes syntax, types, performance and
more. neovim chose a different path: Lua. Because of this, neovim did **not** adopt vim9script, but
is still backwards compatible with the "old" vimscript.

> If you are interested in learning vimscript, I recommend you read
[this](https://learnvimscriptthehardway.stevelosh.com).

There is also an effort to transpile vim9script to Lua for use in neovim core, called
[vim9jit](https://github.com/tjdevries/vim9jit) which has already produced Lua code that is in
neovim core today!

If you plan on using neovim, you should be familiar with both vimscript and Lua. They are
interoperable, but certain APIs only exist in vimscript, and certain APIs only exist in Lua.

neovim has chosen Lua as their primary scripting language which I personally really like. It is fast
because of [LuaJIT](https://luajit.org), very simple and very flexible. It's a great _scripting_
language and allows neovim to do amazing things, that would either be impossible in vim or just
really difficult and cumbersome. Part of it being "simple" also results in it being
"verbose". Mainly it uses keywords instead of symbols, like many other languages do. For example,
this is what an if statement looks like in Lua:

```lua
if balls then
  print("Hello, world!")
end
```

Parentheses and semicolons are optional, any block ends with an `end`, this includes `if`s, loops,
and `do` blocks (subscopes).

Lua is simple enough to be learned in an afternoon, so give it an hour or two to pick up the basic
syntax of it. A really important concept in lua is the **table**. A table is the only data structure
that exists in Lua. There are no arrays or maps, just tables! However, tables can be used to
represent both of these.

```lua
local my_array = { 1, 2, 3 }

local my_map = {
  hello = "world",
  foo = "bar",
}
```

Lua table entries can take anything as a key and anything as a value. If I say "anything", I mean
anything.

```lua
local my_table = {}

-- This is valid Lua :)
my_table[my_table] = my_table

-- This is also valid! A function as a key??? Fuck yeah!
my_table[function() print("balls") end] = true
```

Tables also have "meta methods" which are kind of like operator overloading in other languages.
I recommend you give tables a good look and understand their syntax, they are used _everywhere_.

#### neovim-specific Lua

Earlier I said Lua was verbose; I said that in comparison to vimscript. vimscript is very terse and
compact, so to give a simple example:

```vim
" vimscript
set number
```

```lua
-- Lua
vim.opt.number = true
```

Both of these enable the `number` option. For basic editor configuration you will find that Lua is
overall more code than vimscript, but where it really shines (in my opinion) is when it comes to
actually _scripting_ the editor. Whenever I write actual logic I find that Lua is _a lot_ easier to
understand and reason about. Not only that, but it's a lot faster than vimscript too, and there's
a lot of really cool neovim APIs that are only exposed in Lua.

To read more about neovim-specific Lua, open it up and run `:help Lua`.

### Treesitter

[Treesitter](https://tree-sitter.github.io/tree-sitter) is a parsing library / engine. It is used
for parsing any text into an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) given
a "grammar". This happens to be really useful for text editors, specifically _code_ editors!
Treesitter is mainly known for its syntax highlighting capabilties, as it is much more accurate than
traditional regex-based highlighting engines. It is a lot faster at parsing code, can parse it
incrementally, and is very robust against "incorrect" code. Most of the times, while you are typing,
the code in your editor window is incorrect. It has syntax errors, and most highlighting engines
will quickly give up and highlight things incorrectly until the code is free of errors. Treesitter
is not like this. It can have incorrect / incomplete nodes in its tree and still highlight most of
it correctly. It also does not reparse the entire tree on every keypress, which helps a lot with
performance.

> neovim has treesitter built in, but as of writing this it is still pretty difficult to use without
> any help from plugins. I really hope this will change in the future, and if you absolutely must,
> you _can_ use it without plugins. It is not as mature as for example the builtin LSP client
> though, so using a plugin is pretty much necessary.

The main feature you probably want from Treesitter is syntax highlighting. It's much more accurate
and nuanced than the default regex highlighting. However, you can do a lot more fun things with it
too, including custom motions and text objects, which I will go over in different parts later.

### LSP

The [Language server protocol](https://microsoft.github.io/language-server-protocol) is a protocol
created by Microsoft that serves as an abstraction between editors and static analysis tools
("language servers"). The idea here is that every language only needs to implement a single static
analysis tool (i.e. a language server) and any editor that is able to act as an LSP client can then
use it.

This is the basic premise of LSP; you have 2 components: a "client" and a "server". The "client" in
this case is neovim. This is an important concept to understand, as most people are not aware of it.
Back in the day (aka. pre-2016) static analysis was editor specific; each editor and each language
needed a match; a so called "`n*m` problem". For `n` editors and `m` languages, you need `n*m`
tools. LSP turns this into an `n+m` problem. `n` editors implement the client side of LSP and `m`
languages implement the server side of LSP, and everything _just works_! This means that you
generally don't need a "javascript plugin" or "rust plugin" to get all the language smarts you're
used to from VSCode or similar. All you need is to configure your LSP client: neovim.

I think that static analysis is a really important part of writing code and LSP provides a decent
solution for this. I don't think it's the best solution for every language, but it happens to be the
best for Rust, which is the language I use mainly. There are a lot of other ways of working with
static analysis tools in both vim and neovim which I will touch on in other sections.

There are a lot of plugins that are supposed to make configuring LSP easier, and a lot of them do,
but a lot of crap has also emerged, so I will try to shed some light on how LSP actually works
within neovim, how you can use it, what each of the popular plugins do you might have heard about,
and what I think you "should" use.

> Personal opinion alert: I don't think setting up LSP for <your language> is difficult with
> 0 plugins. I do think that it's easier with the correct plugins. I also think there's a lot of
> plugins that try to make it easier and in the process make it more confusing instead.

How exactly all of this works and how to set it up I will go over in other sections.

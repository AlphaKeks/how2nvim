# Getting to know your editor

In this section I will cover more details about **configuring** and **extending** neovim as an
editor. This will partially apply to vim as well, so I will explicitly mention anything that is
neovim-exclusive. It's also kind of over the place with random topics, as I don't really see an
order here, just pick and choose what you're interested in :)

As I already mentioned, neovim heavily invests into Lua. This means that you can write your
entire configuration using Lua! (There are some exceptions to this, such as the `autoload/`
directory, but for the most part everything just works with Lua)

## Where to put configuration

neovim adheres to the [XDG base directory standard](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).
This means that your configuration will live in `$XDG_CONFIG_HOME`, while files like logs or plugins
will go into `$XDG_DATA_HOME` and `$XDG_STATE_HOME`.

On Linux and MacOS these directories will be the following by default:

- `$XDG_CONFIG_HOME` => `~/.config/nvim`
- `$XDG_DATA_HOME` => `~/.local/share/nvim`
- `$XDG_STATE_HOME` => `~/.local/state/nvim`

For Windows it will be these:

- `$XDG_CONFIG_HOME` => `~/AppData/Local/nvim`
- `$XDG_DATA_HOME` => `~/AppData/Local/nvim-data`
- `$XDG_STATE_HOME` => `~/AppData/Local/nvim-data`

You can also check these directories using

- `$XDG_CONFIG_HOME` => `:echo stdpath('config')`
- `$XDG_DATA_HOME` => `:echo stdpath('data')`
- `$XDG_STATE_HOME` => `:echo stdpath('state')`

Once you have found your config directory, create **either** an `init.vim` **or** an `init.lua` file
inside of it. This will be the entry point for your config. I will talk about other relevant
directories later, but any code examples I show you can put into your `init.{vim,lua}` file. It's
also worth mentioning that you can run any vimscript code in command mode (`:`), and run any Lua
code using the `:lua` vimscript command. `:lua=` followed by a Lua expression will print the result
of that expression.

## Options

The most basic way of customizing vim is using **options**. There are a lot of them
(see `:help option-list`), and they are all documented. You can look up the documentation for
a particular option using `:help '<option>'`, e.g. `:help 'number'` for the `number` option.

In this section I will go over some "must haves" that you should know about, but there are too many
in total to mention them all. Looking at `:help option-list` or other people's configurations is
a good way of finding more!

But before I dump a bunch of code, let me explain the different **types** of options and how you set
them from both vimscript and Lua.

### Strings

You can set string options like so:

```vim
" vimscript

set option=value
```

```lua
-- Lua

vim.opt.option = "value"
```

An example for this is `:help 'mouse'`. It controls which modes to enable mouse support for. By
default the value for this option is `"nvi"`, which means normal, visual, and insert mode. To
disable the mouse entirely, you can set it to an empty string:

```vim
" vimscript

set mouse=
```

```lua
-- Lua

vim.opt.mouse = ""
```

Or, to enable it only in normal mode:

```vim
" vimscript

set mouse=n
```

```lua
-- Lua

vim.opt.mouse = "n"
```

You get the idea!

### Numbers

Numbers follow the same syntax as Strings.

```vim
" vimscript

set option=69
```

```lua
-- Lua

vim.opt.option = 69
```

An example of this is `:help 'tabstop'`, which controls how wide tab characters (`\t`) should be
displayed as. By default this value is 8, so when you hit `<Tab>`, it will insert an invisible
character that is as wide as 8 spaces. Most people will set this value to 4, and this is how you do
it:

```vim
" vimscript

set tabstop=4
```

```lua
-- Lua

vim.opt.tabstop = 4
```

### Booleans

Booleans have quirky syntax in vimscript. They don't follow the same `set option=value` pattern as
before, but instead simply `set option` to enable them, and `set nooption` to disable them. An
example that will enable line numbers:

```vim
" vimscript

set number
```

```lua
-- Lua

vim.opt.number = true
```

To disable the line numbers again:

```vim
" vimscript

set nonumber
```

```lua
-- Lua

vim.opt.number = false
```

### Lists

These are options that take multiple string values as their value. One of these is `wildoptions`,
which controls how tab-completion works in command mode. To set these options use the following
syntax:

```vim
" vimscript

set wildoptions=fuzzy,pum

" appending to an existing list
set wildoptions+=fuzzy
```

```lua
-- Lua

vim.opt.wildoptions = "fuzzy,pum"

-- or as a table!
vim.opt.wildoptions = { "fuzzy", "pum" }

-- appending to an existing list
vim.opt.wildoptions:append("fuzzy")
```

### Dictionaries

These are key-value pairs. They follow a similar syntax as lists, where key and value are separated
by a `:`. The `:help 'listchars'` option controls how different whitespace characters should be
displayed. For example, to make tabs appear as `│` characters, and trailing spaces as `-`, you can
set the following option:

```vim
" vimscript

" the `\` here is escaping the space
set listchars=tab:│\ ,trail:-
```

```lua
-- Lua

-- we don't need to escape the space here since we have proper stings
vim.opt.listchars = "tab:│ ,trail:-"

-- or as a table!
vim.opt.listchars = {
  tab = "│ ",
  trail = "-",
}
```

> By the way, you can check the current value of an option using `:set <option>?`.
> Example: `:set tabstop?` or `:set expandtab?`

## Useful options to consider

Now that you know all the different option types and how to set them, let me go over a few options
I think you should include in your config.

### Indentation

- `tabstop` controls how wide tab (`\t`) characters are
- `expandtab` will insert spaces anytime you hit the tab key, instead of an actual tab character (if
  you're _that_ kind of person)
- `shiftwidth` controls how many spaces are inserted if you have `expandtab` set. It also controls
  how far text is shifted when [in|de]dented using the `<` and `>` operators.
- `autoindent` will make sure to keep text indented as you enter new lines
- `smartindent` will try to figure out the indentation level when entering a new line

### UI

- `number` will show line numbers
- `relativenumber` will display any line number that is not your current line as a relative offset
  rather than an absolute number. This is really useful for relative jumps like `8j`, because all
  you have to do to jump to a specific line is to look to the left of your screen, read how many
  lines it is away from your current line and prefix `j` or `k` with that number. With absolute
  numbers you have to do the math yourself!
- `laststatus` controls how many statuslines there are. I recommend a value of 3, which means there
  will always be a single global statusline
- `wrap` will make text softwrap if it's longer than your screen is able to display
- `colorcolumn` will color a specific column in a different color. This is a nice guide for limiting
  the maximum length of lines, although it is only visual. I like to set this to whatever maximum
  line length is enforced by my formatter + 1.

### Search

- `hlsearch` will control whether matches to a search with `/` will stay highlighted after you hit
  enter.
- `incsearch` when set to `true` will incrementally highlight any matches while you are typing out
  your search.
- `ignorecase` will make searches case-insensitive.
- `smartcase` will make searches case-sensitive if a capital letter is used, and case-insensitive
  otherwise.

## Keymaps

The second major way of customization is **keymaps**. These are analogous to "keybindings" in other
editors, except that they're much more powerful.

Key maps are a mapping from one set of keys to another set of keys. Pretty simple, right?

For instance, opening vim's builtin file explorer netrw is as easy as typing `:Ex` and hitting
enter. But what if you wanted to just press 2 keys instead?

```vim
" vimscript

nnoremap <Space>e :Ex<CR>
```

```lua
-- Lua

vim.keymap.set("n", "<Space>e", ":Ex<CR>")
```

Let's talk about the Lua version first, because I think it makes more sense.

- `vim.keymap` - a module containing functions for controlling keymaps
- `set` - creates a new keymap
  - `n` - normal mode
  - `<Space>e` - the sequence of keys you want to press
  - `:Ex<CR>` - the sequence of keys you want to actually trigger

> If you read [Introduction to vim as an editor](./vim.md) you know what `<CR>` means, but if you
> didn't, it means "enter"

Let's disect the `nnoremap` command from the vimscript version. The first `n` represents the mode
(normal mode). `nore` means "not recursive" (we will talk about that in a moment). `map` means
"create a keymap". And the rest should be self-explanatory.

"not recursive" means that, if you defined another mapping which _triggers_ `<Space>e`, it shall
**not** trigger this custom map (i.e. _recurse_ into more custom mappings). This is usually what you
want, and the default behavior or `vim.keymap.set`. To make a mapping recursive, simply use `nmap`
in vimscript, or pass `{ remap = true }` as a fourth argument into `vim.keymap.set`. There's more
options you can pass which you can read about in `:help vim.keymap.set`.

`vim.keymap.set` also allows for multiple modes and callback functions instead of strings! If you
pass an array-like table of strings as the first argument, the keymap will apply to all the listed
modes. If you pass a function as the third argument, that function will be called when you hit the
specified keys. For example:

```lua
vim.keymap.set("n", "<Space>e", vim.cmd.Ex)
```

`vim.cmd` is a module which contains functions corresponding to any available vimscript command.
`vim.cmd.Ex` is therefore a function which will trigger the `:Ex` command. Note that we don't _call_
the function; we pass the function itself as a value! This also works with anonymous functions:

```lua
-- Pressing space followed by `e` in normal or visual
-- mode will open netrw and print a message.
vim.keymap.set({ "n", "v" }, "<Space>e", function()
  vim.cmd.Ex()
  print("we called the file explorer!")
end)
```

> `vim.cmd` is also a function thanks to Lua's magic metatables! This means you can call it with any
> string you want, and it will interpret that string as vimscript. Example: `vim.cmd("echo 'hi'")`

Saner defaults and a more ergonomic API make `vim.keymap.set` one of my favorite neovim features.
`nnoremap` is often more concise for simple mappings, but as soon as you want multiple modes or
custom one-off callbacks, Lua is just so much nicer!

## Important directories

Inside your `stdpath('config')` you can have a bunch of other sub-directories which have special
meaning. You can read about them in `:help 'rtp'` but I will give you a quick rundown of the most
important ones here.

### `plugin/` and `after/plugin/`

`plugin/` is the directory for plugin files. Any files in this directory will be automatically
executed on startup. In vim every plugin has the same directory structure as your config, so in your
actual config you're probably not gonna use `plugin/` at all, but rather `after/plugin/` which will
also execute automatically, but **after** `plugin/`. Crazy, right? `plugin/` is meant to **setup**
plugins, executing any necessary code to make them usable. `after/plugin/` is mean to **configure**
plugins _after_ they loaded.

If you want to know more about plugins, see [How to install plugins](./plugins.md).

### `ftplugin/` and `after/ftplugin/`

`ftplugin`s or "filetype plugins" are files which will be executed depending on the filetype. vim
ships with a lot of these already, and if you want to override any of them you should use
`ftplugin/`. For example, to have custom code execute in Lua files you can create
a `ftplugin/lua.vim` or `ftplugin/lua.lua` file. If you just want to run code _in addition_ to the
builtin ftplugin, you can create your files in `after/ftplugin/` instead.

### `lua/`

This directory can hold [Lua modules](#lua-modules).

## Lua Modules

Lua has a module system to split up code. The way it is integrated in neovim you have to create
a `lua/` directory in your config directory; e.g. `~/.config/nvim/lua`. Inside of that directory you
can create **modules**. A module is a file, with the filename being its name. Simple enough, right?

- `lua/balls.lua` is a module called `balls`
- `lua/balls/init.lua` is also a module called `balls`
- `lua/balls/foo.lua` is a module called `balls.foo`

You can export data from these modules using the `return` keyword. Usually people will write
something like this in their modules:

```lua
local M = {}

-- ... other code

return M
```

This creates a table `M` to be returned from your module. You can attach anything you want to that
table and make it available in other modules that way.

To load a module you use the builtin `require` function. It will take a module name as an argument
and return whatever the corresponding module returned. So if the example code above was located in
`lua/balls.lua`, you could write the following in your `init.lua` (or any other lua file):

```lua
-- `balls` is now the `M` we returned earlier
local balls = require("balls")
```

Modules are cached. This means that once you `require` a module, all code inside of it will be
executed and the return value will be cached for any subsequent call to `require`. This sometimes
trips people up, because if your module looks like this:

```lua
return 5
```

And you run `:lua= require("balls")` you get `5` as the result. Now if you change the code, for
example to return 10, and run `:lua= require("balls")` again, you will still get `5`. You can solve
this by either resetting the cache, or by returning functions to mutate state. Since every function
in Lua can be a closure, and your modules are cached, you can have local variables in your modules
and return getters / setters as functions.

```lua
local data = 5

local function get()
  return data
end

local function set(value)
  data = value
end

return { get = get, set = set }
```

To un-cache a module you can set `package.loaded["mymodule"] = nil`.

## "Buffers", "Windows", and "Tabs"

New vim users are often confused about "tabs". This is because the word "tab" has a very different
meaning in most other editors. So when you hear the term "tab" you probably think of something
different than what vim calls "tabs". Simply put, a "tab" is a collection of "windows", each of
which displays a "buffer".

A buffer is vim's in-memory representation of some text. Most of the times this will be a file, but
it doesn't have to be. Thinking of "buffer" as "file" in the beginning is certainly helpful, but we
want to stay accurate, so just keep that in the back of your head. When opening a file with vim,
a buffer for it will be created and the current window will show that buffer.

- Buffers are unique, which means you cannot have multiple buffers of the same file.
- Buffers can be displayed in **windows**, multiple even. 2 windows can show the same buffer, and as
  you edit the buffer in one window, it will change in the other window as well, since it's the same
  underlying memory.

A **window** is a part of the screen that actually displays a buffer. You can switch out the buffer
that a window is displaying at any time, and you can have as many windows as you want (or,
realisitcally, how many fit on your screen). These can all display the same buffer, or different
buffers. You can create a new window below the current one using `:split`. This will create a new
window displaying the same buffer as the previous window. You can also use `:new` to create the
window with an empty buffer inside. If you want a window next to the current one, you can use
`:vsplit` and `:vnew` respectively. See `:help windows` for more information.

A **tab** is a collection of windows. By default there is always one tab, which holds your default
window. To create a new tab you can run `:tabnew`. See `:help tabpage` for more useful commands.
Some people like tabs, some don't. I personally don't use them often, but it's important that you
understand that they're not the same as "tabs" in most other editors. The closest thing to a VSCode
"tab" is probably a **buffer**.

# `makeprg` and the quickfix list - basic static analysis workflow

I've mentioned previously how vim is supposed to be combinded with other tools, especially for
static analysis. I'm going to go into detail with this now and give some simple and advanced
examples for both JavaScript and Rust, but everything I cover here is applicable to basically any
language or environment.

## `makeprg` and `:compiler`

The `makeprg` option (see `:help 'makeprg'`) is essentially a proxy to `:!<your build tool>`.

> If you don't know what `:!` does yet: it lets you execute shell commands

By default it will be set to `make` which is a very popular command runner in the Linux world.
However, depending on your needs you can of course adjust this. Rust for example uses `cargo` as the
main build tool, so you could put `setlocal makeprg=cargo` in your `after/ftplugin/rust.vim`. Now
you can run `:make build` to build your project, `:make run` to run your project, or `:make fmt` to
format your project! Basically anything you would tell cargo to do normally, you now tell `:make`.
This has some advantages over just running `:!cargo` though. The main one is automatic error
parsing. There is an option called `errorformat` which tells vim how to extract certain information
from an input string. There is a handy `:compiler` command that has presets for a lot of compilers
(or just tools in general) so you don't have to set `makeprg` and `errorformat` yourself. For rust,
putting `compiler cargo` in `after/ftplugin/rust.vim` should do the trick! Type `:compiler ` and hit
tab to get a list of everything that's supported.

Now anytime you run `:make build`, the compiler's output will be parsed and put into your quickfix
list.

## The quickfix list

The quickfix list is a really useful tool. It essentially allows you to put anything you want in
a persistent list of things. This might not sound very interesting at first, but it integrates
deeply with vim itself as well as a lot of plugins. For a deep dive I recommend you read
`:help quickfix`. A quick rundown of its core commands:

- `:copen` to open the quickfix window
- `:cclose` to close the quickfix window
- `:cnext` to jump to the next message
- `:cprevious` to jump to the previous message

There are many ways to populate the quickfix list. `:make` is one of them. So let's talk about that.

## Edit - Compile - Edit

Once you set your `:compiler` or `makeprg` it's time to write some code! So you go ahead and do
that, and then you run `:make check` (or the equivalent for your language / tooling setup) and like
magic your cursor will jump to the first error that was output by the compiler. Now you can run
`:copen` to open the quickfix list and you will see a list of compiler messages. You can navigate
the quickfix list like any other window and hit enter on any of the messages to jump to that
corresponding error. You can now work through the errors that you got and run the command again to
get new messages. This is a pretty decent workflow, but it has some rough edges; mainly that in
order to update the list you have to rerun `:make`. There is no builtin way of easily removing
entries from the quickfix list. This is why many people write a small helper function to do that and
put it somewhere in their config.

```vim
" vimscript

function! qf_delete_entry()
  let current = line('.')
  let qflist = getqflist()

  call remove(qflist, current - 1)
  call setqflist(qflist, 'r')
  execute ':' . current
endfunction
```

```lua
-- Lua

local function qf_delete_entry()
  local current = vim.fn.line(".")
  local qflist = vim.fn.getqflist()

  table.remove(qflist, current)
  vim.fn.setqflist(qflist, "r")
  vim.fn.execute(":" .. tostring(current))
end
```

You can now map this to a convenient key like `dd` in quickfix buffers by creating an
`after/ftplugin/qf.vim` file and putting the following code inside of it:

```vim
" vimscript

nnoremap <buffer> dd :call qf_delete_entry()<CR>
```

Or, the corresponding Lua version:

```lua
-- Lua

vim.keymap.set("n", "dd", qf_delete_entry, { buffer = true })
```

> Note that your helper function should be defined in the same file so that it's in scope. This
> makes a lot of sense for the quickfix list, but if for whatever reason you don't want to define
> your function in there, you can either define a global Lua function, or put it in a module that
> can be accessed via `require`. In vimscript land you can use the `autoload` functionality.

Now you can very easily delete errors you already fixed without having to recompile!

This is a pretty standard workflow for vim, but we can do better! We use neovim! neovim has a great
Lua API called `vim.diagnostic`. It's a general purpose API for diagnostics that show up as virtual
text right in your code where the errors actually are. This requires a bit of setup but I think
you'll like it.

First we need to define a **namespace** for our diagnostic. Namespaces are a neovim concept to
capture diagnostics, highlights and extmarks, all of which you can read about with `:help`. For
our purposes, we need to create a namespace to hold our diagnosics.

```lua
local namespace = vim.api.nvim_create_namespace("my-cool-diagnostics")
```

We also need to convert the errors from the quickfix list into a format that `vim.diagnostic`
understands; luckily there's a helper function for that.

```lua
local qflist = vim.fn.getqflist()
local diagnostics = vim.diagnostic.fromqflist(qflist)
```

And now we just need to add them to our buffer!

```lua
-- 0 always refers to the current buffer
vim.diagnostic.set(namespace, 0, diagnostics)
```

But where do we even put this code? When will it run? Well, we can define an autocommand for it!

## Autocommands

Autocommands are neovim's event system. A lot of things happening in neovim will emit a certain
event, together with some information about that event. You can hook into this event system using
**autocommands**. `:help autocmd` gives a nice overview of details, but for the purposes of this
guide all you need to know is that there are "events" and "autocommands" which are event
listeners. To see a list of all events refer to `:help events`.

The event we are interested in here is called `QuickFixCmdPost`. A quick look at
`:help QuickFixCmdPost` tells us that this event fires _after_ any quickfix-related command is
ran. This includes `:make`.

Let's create an `after/ftplugin/qf.lua` file.

```lua
local namespace = vim.api.nvim_create_namespace("my-cool-diagnostics")
local group = vim.api.nvim_create_augroup("my-cool-diagnostics", { clear = true })
local buffer = vim.api.nvim_get_current_buf()

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  buffer = buffer,
  callback = function()
    -- Get the current contents of the quickfix list
    local qflist = vim.fn.getqflist()

    -- Convert it to `vim.diagnostic`'s format
    local diagnostics = vim.diagnostic.fromqflist(qflist)

    -- Clear all previous diagnostics
    vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)

    -- Set the new diagnostics
    vim.diagnostic.set(namespace, buffer, diagnostics)
  end,
})
```

> A note on `group`: augroups are used for grouping multiple autocommands and batch-clearing them.
> The `clear = true` we pass to `nvim_create_augroup` means that anytime an autocommand in this
> group is redefined, it should be cleared before being defined again; this way you don't end up
> with multiple instances of the same autocommand. It's by no means necessary but leads to a more
> streamlined workflow as you can simply run the same file multiple times without autocommands
> stacking themselves to infinity. This prevents you from having to restart neovim everytime you
> make a change.

I hope you see the amount of possibilities here! Since this is all _just Lua code_ you can run
_whatever_ tool you want, and make its messages magically appear in a buffer. You don't even need
to use the `:make` architecture, you could run a shell command and parse the output and create your
own diagnostics super easily!

But back to what we were doing. The combination of `makeprg` / `:compiler` and this very simple
autocommand means that we can now run `:make check` and the compiler messages will appear as virtual
text in our buffer, on the same lines that the errors actually happened on. And not only that;
`vim.diagnostic` has a `:cnext` and `:cprev` equivalent akin to the quickfix list that you can use
if you didn't get your diagnostics from the quickfix list like we did here. They are called
`vim.diagnositc.goto_next` and `vim.diagnostic.goto_prev`. You can make keymaps for them anywhere
you want in your config and use them to jump between diagnostics.

Now, this may still be a bit too manual for some people. What if you don't want to run `:make build`
after every change you make? Well, for that we have autocommands! Simply define an autocommand that
runs after saving the buffer:

```lua
vim.api.nvim_create_autocmd("BufWritePost", {
  command = "make check",
})
```

Now, anytime you save a buffer, `:make check` will be ran automatically. Once again, the
possibilities are endless! You can run whatever code you want automatically on save.

## Prettier - formatting on save

"Format on save" is one of the first things new neovim users want to setup (from my experience).
What many of them don't realize is that they don't need a plugin or special complicated setup for
this. It's just autocommands and shelling out to external programs! Remember `:!` which I mentioned
earlier? Well, it can also take a **range** as its first argument. Read `:help [range]` for more
information about what ranges are. For example, to run a shell command and replace the current line
with its output you simply need to prefix it with a `.` like this: `:.!ls` will replace the current
line (and as many lines below that as necessary) with the output of the `ls` shell command!

Prettier - as most formatters - is very simple. It takes code as an input and spits out formatted
code as output. If you never ran prettier from a terminal I suggest you give it a try, it's pretty
easy:

```sh
prettier file.js
```

This will give you back the formatted version as text on stdout. Armed with that knowledge I think
you can already see how we are going to implement this!

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  command = "%!prettier %",
})
```

Here we define an autocommand to run _before_ the buffer gets saved. We tell it to run
`%!prettier %`, which might be a bit confusing because of the double `%`. In general, `%` used in
ranges means "the entire file" while it means "the full path to the current file" in any other case.
So what we're saying here is: "run a shell command called `prettier` and pass the current file path
to it, then replace the current buffer with its output". Unfortunately this has the side effect that
our cursor will be put at the beginning of the buffer. This is quite distracting but can be solved
easily by saving the cursor position before running prettier and restoring it again afterwards:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    -- Get the current cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)

    -- Run prettier
    vim.cmd("%!prettier %")

    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})
```

This is pretty nice! But we also want linting, because we're JavaScript developers and use 10
different tools in every project!

## ESLint - linter diagnostics on save

Now let's combine our knowledge from the previous section with the things we learned at the start
about `vim.diagnostic`.

Shameless as I am, I stole an `errorformat` from the internet that matches ESLint's output:

```lua
vim.bo.errorformat = "%f: line %l\\, col %c\\, %m,%-G%.%#"
```

> I got it from [here](https://gist.github.com/romainl/2f748f0c0079769e9532924b117f9252#help-vim-understand-eslint-output), btw.

Now we can set our `makeprg` to `eslint`:

```lua
vim.bo.makeprg = "eslint --format compact"
```

And to finish it all up:

```lua
local namespace = vim.api.nvim_create_namespace("javascript-is-silly")
local buffer = vim.api.nvim_get_current_buf()

local function run_eslint()
  local old_makeprg = vim.bo.makeprg
  local old_errorformat = vim.bo.errorformat

  vim.bo.makeprg = "eslint --format compact"
  vim.bo.errorformat = "%f: line %l\\, col %c\\, %m,%-G%.%#"

  vim.cmd.make("%")

  local qflist = vim.fn.getqflist()
  local diagnostics = vim.diagnostic.fromqflist(qflist)

  vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
  vim.diagnostic.set(namespace, buffer, diagnostics)

  vim.bo.makeprg = old_makeprg
  vim.bo.errorformat = old_errorformat
end

local function run_prettier()
  local cursor = vim.api.nvim_win_get_cursor(0)

  vim.cmd("%!prettier %")
  vim.api.nvim_win_set_cursor(0, cursor)
end

local group = vim.api.nvim_create_augroup("javascript-is-silly", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  buffer = buffer,
  callback = run_prettier,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  buffer = buffer,
  callback = run_eslint,
})
```

# Conclusion

I hope you understand the versatility of `:make`, the quickfix list, `vim.diagnostic` and
autocommands and are able to extend this new-learned knowledge to whatever tool _you_ work with.
Combining external tools with neovim's builtin APIs and event system is both super easy and super
useful. Some other APIs that didn't get to shine here but I think you should know about are:

- `vim.json` for serializing and deserializing json - see `:help vim.json`
- `vim.fn.system()` and `vim.fn.jobstart()` - see `:help system()` and `:help jobstart()`
- `vim.system()` which exists since neovim 0.10 and is therefore a nightly feature as of writing
  this

Combine everything you learned today with those functions and you can compose literally any tool
that works over stdin/stdout with neovim!

A small example that uses `vim.system()` and does the same thing as running `:%!prettier %`, but
asynchronously:

```lua
local command = { "prettier", vim.fn.expand("%") }
local opts = { text = true }

vim.system(command, opts, function(result)
  if result.code ~= 0 then
    print("failed to run prettier")
    return
  end

  local lines = vim.split(result.stdout, "\n")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end)
```

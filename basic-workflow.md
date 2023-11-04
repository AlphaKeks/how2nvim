# A basic development workflow

In this section I will talk about builtin tools that vim has to offer to make your workflow actually
**flow**.

Coming from an IDE with inline error messages, auto-completion and a big green "run" button this
kind of workflow might seem weird to you, but I encourage you to give it a fair try. neovim can have
all those fancy features too (with plugins), but they're opt-in, and you should know both sides.
I personally used neovim for a long time entirely relying on LSP and plugins to even be able to
write code. But now that I've seen both perspectives, I developed my own personal workflow that
includes LSP and semantic completion, but in a way less obvious way, leveraging neovim's builtin
tools as much as makes sense.

## The quickfix list

Unless you're completely new to vim you might have already heard of the **quickfix list**. This list
is a universal place for you to store information that you want to note down and move between
quickly. This could include error messages, search results, or really anything you want.
Traditionally the quickfix list is mostly used with `:make` and `:grep`. So let us have a look at
those commands!

### `:make`

The `:make` command is your entry point to using tools for static analysis. vim does not try to
incorporate all the language-specific functionality any user might need or want. Instead it tries to
give you a framework for composing existing tools that simply work with
[stdin and stdout](https://en.wikipedia.org/wiki/Standard_streams). This means they will take text
or a file as input, and give you back some text on stdout or directly as a file. For example,
[ESLint](https://eslint.org/) is a very popular JavaScript linter that will find problems in your
code. It's a CLI tool which takes text as input, and spits out error messages as output. `:make`
lets you hook up any CLI tool you want by setting the `makeprg` option and will parse its output
according to your current `errorformat` option. While vim or neovim do not provide the tool itself
(i.e. ESLint), they _do_ provide some basic configuration for a lot of tools via the `:compiler`
command. Even though the command is called "compiler", it manages a bunch of tools, including
a large list of linters (including ESLint!). This means, all you need to do is run
`:compiler eslint` and now you can open any JavaScript file you want, run `:make %` and ESLint's
error messages will magically appear in your quickfix list.

### Basic usage of the quickfix list

You can jump between them using the `:cnext` and `:cprevious` commands. `:cclose` will close the
quickfix list if you find it distracting, while `:copen` will open it back up. There is also
`:cwindow` which will only open the quickfix list if there are any errors, and close it otherwise.
For more information see `:help quickfix`.

### `:grep`

The `:grep` command, as the name suggests, will search for text in a given set of files. This
command will use the standard `grep` program found on any Linux system by default, but you can
configure which command it's supposed to use with the `grepprg` option. Similarly to errors, vim
needs to know how to parse the output of your search tool. `grepformat` is what you're looking for
here. I personally use [ripgrep](https://github.com/BurntSushi/ripgrep) as it is by far the fastest
grepping tool on the market right now. If you also want to use it, set the following `grepformat` in
your configuration: `%f:%l:%c:%m`

Now you can run `:grep some text` and all the occurrences of that text in any files in your current
directory, or any sub-directory, will appear in your quickfix list for you to navigate.

I also have this command for convenience:

```vim
command! -nargs=+ Grep silent grep! <args> | copen | redraw!
```

It defines a user command called `Grep` which takes 1 or more arguments and runs `grep` over the
given arguments. It will then open the quickfix list and redraw the screen. It is basically instant
even for millions of lines of code to search through and a real life saver!

Here's the Lua version if you really hate vimscript for some reason:

```lua
vim.api.nvim_create_user_command("Grep", "silent grep! <args> | copen | redraw!", { nargs = "+" })
```

As you can see, it's basically the same, just longer.

## A general workflow

Assuming you have chosen your tools by now, how do you properly set this up?

I will use [ESLint](https://eslint.org/) and [Prettier](https://prettier.io/) as examples here, but
the general concepts are applicable to any CLI tool.

### ESLint

Let's start with ESLint. As mentioned previously, ESLint is already a supported `:compiler` in vim,
so all we need to do is put the following code into `after/ftplugin/javascript.lua`:

```lua
vim.cmd.compiler("eslint")
```

If you now open a JavaScript file and run `:set makeprg?` you should get the following output:
`makeprg=npx eslint --format compact`. This is suboptimal for 2 reasons:

1. It uses `npx` to run eslint.
2. It uses `eslint` instead of [`eslint_d`](https://github.com/mantoni/eslint_d.js).

`eslint_d` is a [daemonized](https://en.wikipedia.org/wiki/Daemon_(computing)) version of `eslint`.
It will keep running in the background after you invoke it for the first time and therefore every
subsequent invocation is going to be a lot faster than waiting for node to do a cold start everytime
you invoke `eslint`. The drawback is that you need to manually restart it when you make config
changes, as it won't detect those automatically. `eslint_d restart` should do the trick.

Because we want to use `eslint_d` instead, we need to adjust `makeprg`:

```lua
vim.cmd.compiler("eslint")
vim.bo.makeprg = "eslint_d --format compact"
```

> We still want `:compiler eslint` since it also takes care of `errorformat` for us.

Now with these setup, you should be able to run `:make %` and get any reported errors into your
quickfix list. Would be convenient if it ran automatically on save, you say? Sure, we can do that.

Let me introduce you to **autocommands**. They are neovim's event system and basically event
handlers from JavaScript. If you want detailed information about them, read `:help autocmd`. For now
though all you need to know is that there's an event called `BufWritePost` which gets emitted
anytime you write a buffer; _after_ you write it. This is exactly when we want to run ESLint.

```lua
vim.cmd.compiler("eslint")
vim.bo.makeprg = "eslint_d --format compact"

-- This ensures we don't create multiple instances of the same autocommand
--
-- See `:help autocmd-groups` and `:help nvim_create_augroup`
local group = vim.api.nvim_create_augroup("eslint-on-save", { clear = true })

-- This is the current buffer's ID
local buffer = vim.api.nvim_get_current_buf()

-- Here we create our autocmd (event listener)
--
-- See `:help autocmd` and `:help nvim_create_autocmd`
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  buffer = buffer,
  callback = function()
    -- This is our current working directory, aka our project root.
    local cwd = vim.fn.getcwd()

    -- Replace `"src"` with whatever directory you keep your code in.
    local src = vim.fs.joinpath(cwd, "src")

    -- Run `eslint_d` on any JavaScript files in our `src` directory
    -- (or sub-directories)
    vim.cmd.make(src .. "/**/*.js")
  end,
})
```

Now, anytime you save, `eslint_d` will lint your code and your quickfix list will be filled with its
diagnostics. This also has the side effect that you cursor will automatically jump to the first
error; if you don't want that, replace `vim.cmd.make(src .. "/**/*.js")` with
`vim.cmd("make! " .. src .. "/**/*.js")`. The `!` in `make!` will cause it _not_ to jump to the
first error automatically.

Since we use neovim, we can do even better than this. neovim has a dedicated `vim.diagnostic` API to
display diagnostics as virtual text inside buffers. This means we can take the messages in our
quickfix list and make them appear on the exact lines they are complaining about! And it doesn't
take a lot of code either; `vim.diagnostic` has utility functions for exactly this.

```lua
-- This is similar to the autocmd group we saw earlier, but for diagnostics, highlights and other
-- neovim-only things.
--
-- See `:help namespace`
local namespace = vim.api.nvim_create_namespace("eslint-diagnostics")

-- The `QuickFixCmdPost` event fires anytime the quickfix list is modified.
-- See `:help QuickFixCmdPost`
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  buffer = buffer,
  callback = function()
    -- Get our quickfix list
    local qflist = vim.fn.getqflist()

    -- Transform it into diagnostics
    local diagnostics = vim.diagnostic.fromqflist(qflist)

    -- Clear out any old diagnostics
    vim.diagnostic.reset(namespace, buffer)

    -- Populate the current buffer's diagnostics
    vim.diagnostic.set(namespace, buffer, diagnostics)
  end,
})
```

And with that, we are now running `eslint_d` after every buffer we save, analyzing our entire
project, populating our quickfix list, which triggers diagnostics to appear in our buffer. And what
did it take? Less than 30 lines of Lua without the comments!

```lua
vim.cmd.compiler("eslint")
vim.bo.makeprg = "eslint_d --format compact"

local buffer = vim.api.nvim_get_current_buf()
local augroup = vim.api.nvim_create_augroup("eslint-on-save", { clear = true })
local namespace = vim.api.nvim_create_namespace("eslint-diagnostics")

vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = buffer,
  group = augroup,
  callback = function()
    local cwd = vim.fn.getcwd()
    local src = vim.fs.joinpath(cwd, "src")

    vim.cmd.make(src .. "/**/*.js")
  end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  buffer = buffer,
  group = group,
  callback = function()
    local qflist = vim.fn.getqflist()
    local diagnostics = vim.diagnostic.fromqflist(qflist)

    vim.diagnostic.reset(namespace, buffer)
    vim.diagnostic.set(namespace, buffer, diagnostics)
  end,
})
```

If you are bothered by `:make` being synchronous you can consider using
[vim-dispatch](https://github.com/tpope/vim-dispatch). If you are on neovim 0.10 or higher you can
also use `vim.system()` to asynchronously run shell commands (you can also use `vim.fn.jobstart()`
if you are on an older version). Combined with `vim.json` you could
just call `eslint_d --format json` and parse the results and build diagnostics from it
yourself!

Okay, now with ESLint out of the way, let's look at Prettier.

### Prettier

Once again, there is a faster alternative to the standard `prettier` called
[`prettierd`](https://github.com/fsouza/prettierd). Same concept as `eslint_d`, same drawback of
having to restart it using `prettierd restart` anytime you change its config. Let's implement it!
We will continue in `after/ftplugin/javascript.lua` and reuse our `augroup` and `buffer` variables
from before.

```lua
-- This time we want to run our logic *before* we save. This is because we will swap out the buffer
-- contents with prettier's output right before it actually gets written to disk.
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = buffer,
  group = group,
  callback = function()
    -- Full path to the current file
    local filename = vim.fn.expand("%")
    local command = { "prettierd", filename }
    local opts = {
      -- Treat stdout as raw text
      text = true,

      -- We will feed prettier our current buffer contents as input via stdin.
      stdin = vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
    }

    -- You can also use `vim.fn.system()` here if you are on neovim <0.10.
    -- See `:help system()`
    local result = vim.system(command, opts):wait()

    if result.code ~= 0 then
      -- Prettier will return an error if the file has sytnax errors, so we just exit silently.
      return
    end

    -- Take prettier's output and turn it into an array of lines
    local formatted_lines = vim.split(result.stdout, "\n", { trimempty = true })

    -- Replace the current buffer's contents with those new lines
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, formatted_lines)
  end,
})
```

Now, anytime we save a buffer, we call `prettierd` with our current buffer contents as input,
receive back a formatted version via stdout and replace our buffer with that. Beautiful!

### Wrapping up

Currently all of this only works for JavaScript files, but what if you wanted to share that logic?
Both ESLint and Prettier work with TypeScript as well, and Prettier in particular can format many
other filetypes as well, like HTML for example. So how do we share logic? Lua modules!

If you read [Getting to know your editor](./getting-to-know-nvim.md) you already know how Lua
modules work. If you don't know how they work, read
[this section](./getting-to-know-nvim.md#lua-modules).

I personally group all my files under a module called `alphakeks` so none of them clash with plugins
or builtin modules. This means I would create a file called `lua/alphakeks/eslint.lua` with all my
ESLint related functions.

```lua
local namespace = vim.api.nvim_create_namespace("eslint-diagnostics")

local file_patterns = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
}

local function invoke(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()

  local config_files = vim.fs.find(file_patterns, { upward = true })

  -- I don't want to run eslint if the current project does not have a configuration for it.
  if #config_files == 0 then
    return
  end

  vim.cmd.compiler("eslint")
  vim.bo[buffer].makeprg = "eslint_d --format compact"

  -- Run eslint on the current file
  vim.cmd("make! %")

  local qflist = vim.fn.getqflist()
  local diagnostics = vim.diagnostic.fromqflist(qflist)

  vim.diagnostic.reset(namespace, buffer)
  vim.diagnostic.set(namespace, buffer, diagnostics)
end

local function on_save(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()

  return vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buffer,
    group = vim.api.nvim_create_augroup("eslint-on-save"),
    callback = function()
      invoke(buffer)
    end,
  })
end

return {
  namespace = namespace,
  invoke = invoke,
  on_save = on_save,
}
```

Now I can simply call `require("alphakeks.eslint").on_save()` in `after/ftplugin/javascript.lua` as
well as `after/ftplugin/typescript.lua`.

For Prettier you can do something very similar:

```lua
local function invoke(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()

  local filename = vim.fn.expand("%")
  local command = { "prettierd", filename }
  local opts = {
    text = true,
    stdin = vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
  }

  local result = vim.system(command, opts):wait()

  if result.code ~= 0 then
    return
  end

  local formatted_lines = vim.split(result.stdout, "\n", { trimempty = true })

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, formatted_lines)
end

local function on_save(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()

  return vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buffer,
    group = vim.api.nvim_create_augroup("prettier-on-save"),
    callback = function()
      invoke(buffer)
    end,
  })
end

return {
  invoke = invoke,
  on_save = on_save,
}
```

And again, you only need `require("alphakeks.prettier").on_save()` in all your `ftplugin` files.

## Conclusion

I hope you see how much you can do with very little code. Anything I showed you here is applicable
to any CLI tool and once you've done it a few times, scripting neovim will become really easy and
feel very satisfying. Lua is an elegant language, neovim has a very useful API and there are lots of
tools that work over stdin/stdout, so don't be afraid not finding a plugin for your favorite tool;
just integrate it yourself!

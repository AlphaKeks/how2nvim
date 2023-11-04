# LSP

## What is LSP?

The [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) is a protocol
which defines a standard way of how a code editor and a static analysis tool should communicate.

The basic premise of the protocol is that you have a client and a server. The client is your text
editor (neovim in this case) and the server is some external process that communicates with a client
over [RPC](https://en.wikipedia.org/wiki/Remote_procedure_call). A client can start a server as an
external process and the two communicate with messages. This allows a server to analyze the current
file you're editing without having to care about how that information is represented. It's your
editor's (client) job to interpret the response from the server and showing you the errors.

In the past every editor had to implement their own language specific support (and some still do),
which lead to an `n * m` problem. You have `n` editors and `m` languages, so you need `n * m`
plugins for every language to be supported in every editor. With LSP you simply need every editor to
implement the client side of the protocol and every language to implement the server side; an
`n + m` problem!

While this sounds great in theory, the protocol itself is lacking in some areas and a lot of
languages just don't have great implementations (language servers), especially languages that are
dominated by IDEs such as Java or C#. [JetBrains](https://www.jetbrains.com/) especially being the
lead in the IDE space has their own analysis tools built into their IDEs which are a lot more
powerful than most LSP server implementations. Nonetheless, the idea behind the protocol is great
and the languages which do have good support for it benefit greatly from it, as they have to invest
a lot less work to be "supported" by a lot of different editors.

## How LSP is implemented in neovim

neovim is one of these editors which implement the client side of LSP. Specifically the `vim.lsp`
Lua module exposes all that functionality, as everything is implemented in Lua directly.

LSP describes this concept of "capabilities", which are parts of the spec which clients and servers
may implement, but are not forced to. When establishing a connection, client and server will
exchange capabilities and agree on the set of capabilities which are implemented by both. You can
then make requests to a server using specific **methods** supported by those capabilities. There are
a lot of these, but I want to list a few examples so you can have a mental model of how it works:

- `textDocument/definition` will find the location of the definition of a symbol (e.g. a variable)
- `textDocument/references` will find all locations where a symbol is referenced
- `textDocument/hover` will give you certain information about a symbol you'd expect when hovering
  over it with a mouse (neovim implements this using Lua functions, of course, but remember that
  this protocol was made by the same people who made VSCode)
- `textDocument/completion` will give semantic completion for a given piece of text

The list goes on, but I think you get the idea. All of these methods that are supported by neovim
are exposed as Lua functions, with sensible default behavior. These functions are called "handlers".
They all have the same signature and you can override them either globally, per server, or per
request, if you see the need to. For more information on handlers, see `:help lsp-handler`. For
a list of all handlers, see `:help lsp-handlers`.

So the way **you** are mostly going to interact with LSP is using functions in the `vim.lsp` module,
mainly the `vim.lsp.buf` module which holds functions that are relevant in the context of a buffer.
The functions that correspond to the LSP methods I listed earlier are the following:

- `vim.lsp.buf.definition()`
- `vim.lsp.buf.references()`
- `vim.lsp.buf.hover()`
- `vim.lsp.buf.completion()`

I think you see the pattern.

As of writing this the only function of these that is actually mapped to a key by default is
`vim.lsp.buf.hover()`, which is mapped to `K` in any buffer that has a language server attached to
it. So if you want to use LSP, you should define keymaps for most of these functions, as it takes
forever to type them out by hand :)

> [nvim-lspconfig](#nvim-lspconfig) has a bunch of example mappings in their README, if you can't
> come up with any.

### Starting a language server

Okay, understanding the high level is cool and all, but how do we use it? Simple: `vim.lsp.start`

If you read `:help LSP` you will see the first section mention this function. It is responsible for
spawning the external process that is your language server and establishing a connection.

> Earlier I said that neovim was the client part of LSP; that was kind of a lie. What actually
> happens is that neovim **creates** a client anytime you start a server, so that there is always
> a 1:1 mapping of client <-> server. neovim just "manages" these clients so to speak.

The function can take a bunch of parameters which you can read about in `:help vim.lsp.start()` but
I want to focus on the essentials.

```lua
vim.lsp.start({
  name = "my cool language server",
  cmd = { "/path/to/server" },
  root_dir = "/path/to/project/root",
})
```

The `name` of the server is internal to neovim; you can call it whatever you want (using a sensible
name is recommended, though). The `cmd` is the command used to spawn the server; after all neovim
does not include language servers, they are installed separately. `root_dir` is the root directory
of your project. Most languages have an idea of a "project"; in JavaScript you have a `package.json`
file at the root, in Rust you have a `Cargo.toml`, etc.

The language server will need to know where your project is, and that's what `root_dir` is for. To
make life easier for yourself you can define a small helper function to make finding the root
directory easier:

```lua
local function find_root(patterns)
  -- Use the current working directory as a fallback
  local cwd = vim.fn.getcwd()

  -- Search for files that match the given `patterns`
  local matches = vim.fs.find(patterns, { upward = true })

  if vim.tbl_isempty(matches) then
    -- We could not find our root files
    return cwd
  end

  -- Get the parent directory of the first match
  local root_dir = vim.fs.dirname(matches[1])

  if root_dir == nil then
    -- If it doesn't have a parent directory (for whatever reason), return the cwd as well
    return cwd
  end

  return root_dir
end
```

Let's set up [rust-analyzer](https://rust-analyzer.github.io/) as an example to demonstrate how to
use this function:

```lua
vim.lsp.start({
  name = "rust-analyzer",
  cmd = { "rust-analyzer" },
  root_dir = find_root({ "Cargo.toml" }),
})
```

Now, calling the function like this will immediately load the language server, but ideally we only
call it when we are in a Rust project. For language servers like rust-analyzer which only support
a single language, you can simply put the call to `vim.lsp.start` into `after/ftplugin/rust.lua`.
Other servers like the
[typescript-language-server](https://github.com/typescript-language-server/typescript-language-server)
however work for multiple languages; TypeScript and JavaScript in this case. So you probably want to
wrap the call to `vim.lsp.start` in a function which you export from a module and then `require` in
`after/plugin/typescript.lua` and `after/plugin/javascript.lua`. If you don't know how modules work,
checkout [this section](./getting-to-know-nvim.md#lua-modules).

An example of such a setup would be the following:

```lua
-- lua/alphakeks/lsp.lua

local function find_root(patterns)
  local cwd = vim.fn.getcwd()
  local matches = vim.fs.find(patterns, { upward = true })

  if vim.tbl_isempty(matches) then
    return cwd
  end

  local root_dir = vim.fs.dirname(matches[1])

  return vim.F.if_nil(root_dir, cwd)
end

return { find_root = find_root }
```

```lua
-- lua/alphakeks/lsp/tsserver.lua

local function start()
  vim.lsp.start({
    name = "tsserver",
    cmd = { "typescript-language-server", "--stdio" },
    root_dir = require("alphakeks.lsp").find_root({ "package.json" }),
  })
end

return { start = start }
```

```lua
-- after/ftplugin/typescript.lua

require("alphakeks.lsp.tsserver").start()
```

```lua
-- after/ftplugin/javascript.lua

require("alphakeks.lsp.tsserver").start()
```

### [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

This however is a lot of boilerplate. Most servers have defaults that will apply on basically any
system and you probably don't want to care about those details. This is where
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) comes into play. It's a plugin maintained
by the neovim team, but external to neovim because it gets updated a lot more frequently. It's
a collection of useful commands and preset configs for a ton of language servers. It reduces all the
boilerplate I just showed you to basically

```lua
require("lspconfig").rust_analyzer.setup({})
require("lspconfig").tsserver.setup({})
```

This `.setup()` function will take the same arguments as `vim.lsp.start` and override any defaults
it has set internally, if you specify them. You can see a list of supported language servers as well
as all their default settings
[here](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

It's important to note that `.setup()` will **not** immediately start a language server. Instead, it
will setup **autocommands** to start them when appropriate. This means you should **not** have these
in `after/ftplugin`. Put them in `after/plugin/lsp.lua` or in a Lua module that is loaded by your
config.

### [mason.nvim](https://github.com/williamboman/mason.nvim)

If you work with a lot of languages you will quickly realize that installing all these servers is
a mess. Each one uses a different package manager and keeping versions in sync and making sure
everything is installed when setting up a new machine is just a pain in the ass.

> Unless you use something like [nix](https://nixos.org/) of course :)

This is why the community has come up with a plugin to solve this.
[mason.nvim](https://github.com/williamboman/mason.nvim) still requires you to have all the package
managers installed, but it will handle the installation of the tools, as well as keeping them
isolated from the rest of your system. No more `sudo npm i -g typescript-language-server`!

Mason can also handle other tools for you, like formatters or linters, which aren't language servers
but still useful tools you might want installed alongside your editor.

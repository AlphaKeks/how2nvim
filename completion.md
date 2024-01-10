# Insert Completion

While most people use some sort of auto-completion plugin, vim and neovim actually have pretty
decent completion functionality built-in. If you take a look at `:help ins-completion` you will see
a list of various completion sources, like buffer words, entire lines, file paths, tags, dictionary
words, and more. To be fair, some of these are pretty useless. When writing code you will probably
not find yourself using a thesaurus very frequently. However, there are two completion mechanisms
that stand out here: `userfunc` and `omnifunc`. Both work the exact same way, don't ask me why
there's two of them; for simplicity's sake I'm just going to say "omnifunc" from now on, but I mean
both, technically.

`:help 'omnifunc'` will link you to another help page, namely `:help complete-functions`, which
explains in detail how to write your own `omnifunc`. Many of these already come with vim and will be
set automatically based on your filetype. neovim also ships with `vim.lsp.omnifunc` which will be
set automatically when a language server attaches to the current buffer. This will give you
completions supplied by any attached language servers.

While `omnifunc` does allow for quite powerful completion, especially when combined with LSP, the
"framework" around it is not very flexible. Plugins like
[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) have become really popular for two reasons:

- They provide actual **auto**-completion
- They are much easier to use and extend than `omnifunc`

I really wish this was different, but hey, here we are.

## Setting up [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

> If you don't know how to install plugins, read [How to install plugins](./plugins.md).

The first thing you'll want to do is install [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) as
a plugin. You will also need a **snippet engine**, the most popular of which nowadays is
[LuaSnip](https://github.com/L3MON4D3/LuaSnip). This is necessary for expanding snippets coming from
e.g. your LSP.

On that note, nvim-cmp requires you to install completion **sources**, which are responsible for
sending completions to nvim-cmp, which can then display them. A non-exhaustive list of sources you
may want to consider:

- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) for LSP completion
- [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) for buffer word completion
- [cmp-path](https://github.com/hrsh7th/cmp-path) for file system path completion
- [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) for snippet completion (assuming you
  use LuaSnip)

After installing it you need to call its `.setup()` function somewhere in your config:

```lua
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  -- Here you can put keymaps for completion
  mapping = cmp.mapping.preset.insert({
    -- Confirm a completion
    ["<CR>"] = cmp.mapping.confirm(),

    -- Cancel the completion
    ["<C-e>"] = cmp.mapping.abort(),

    -- Force the completion menu to open
    ["<C-Space>"] = cmp.mapping.complete(),

    -- Select the next item
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end),

    -- Select the previous item
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end),
  }),

  -- Here you can put your list of completion sources.
  --
  -- The order is important. It determines the priority of each source and affects how they will
  -- appear in your completion menu.
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
})
```

Another important thing to note here is that by default LSP servers will not send certain
completions unless you tell them to. This is because of **capabilities**, as I have talked about in
the [LSP](./lsp.md) section of this repo. [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
exposes a function for these extended capabilities, which you should pass to each server's setup to
get snippets and auto-imports.

```lua
-- If you use `vim.lsp.start`, this will be the exact same. lspconfig's `.setup()` function takes
-- the same arguments as `vim.lsp.start`.
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
})

lspconfig.tsserver.setup({
  capabilities = capabilities,
})

lspconfig.lua_ls.setup({
  capabilities = capabilities,
})

-- ...
```

## Writing a simple `omnifunc` for LSP

> This section exists mostly for fun. If you just want completion to work, and especially if you
> want **auto**-completion, I highly recommend [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

We will start by creating a file to put this function in. Let's say `lua/alphakeks/completion.lua`.

```lua
---@param findstart 0 | 1
---@param base string
local function omnifunc(findstart, base)
end

return { omnifunc = omnifunc }
```

This is the outline for it. In another file, probably an `LspAttach` autocmd we can then set this as
our `omnifunc`:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.bo[event.buf].omnifunc = "v:lua.require('alphakeks.completion').omnifunc"
  end,
})
```

Our function will be called twice each time we press `<C-x><C-o>`. In the first call `findstart`
will be `1`, signalling that we need to find the start column of our completion.

```lua
---@param findstart 0 | 1
---@param base string
local function omnifunc(findstart, base)
  if findstart == 1 then
    local window = vim.api.nvim_get_current_win()
    local cursor_col = vim.api.nvim_win_get_cursor(window)[2]
    local line = vim.api.nvim_get_current_line():sub(1, cursor_col)
    local start_col = vim.fn.match(line, "\\k*$") + 1

    return start_col
  end

  local words = {}

  return { words = words, refresh = "always" }
end
```

We get our cursor's position and use it to extract the text of the current line up to our cursor. We
then match against `\k*$`, which is vim regex. `\k` is any "keyword" (see `:help 'iskeyword'`), and
we want the last one so we also match against `$` (the end of the text).

The second time our function is called, `base` will be the text starting at the column returned in
the first call, up to our cursor. Currently we're just returning an empty table for `words`, so we
don't get any errors, but we're actually supposed to return completion items here.
`:help complete-items` has a detailed description of what these are supposed to look like.

To get our completion items, we need to make an LSP request and do some data transformation.

```lua
local function omnifunc(findstart, base)
  if findstart == 1 then
    -- *snip*
  end

  local result = { words = {}, refresh = "always" }

  local buffer = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buffer, method = "textDocument/completion" })

  -- We don't have any LSP clients that can do completion, so we return an empty list.
  if vim.tbl_isempty(clients) then
    return result
  end

  local params = vim.lsp.util.make_position_params()
  local lsp_results = vim.lsp.buf_request_sync(0, "textDocument/completion", params)

  if lsp_results == nil then
    print("No LSP completions")
    return result
  end

  -- Each server could have sent a result, so we need to check each one
  for _, lsp_result in ipairs(lsp_results) do
    if lsp_result.err ~= nil then
      print("Error while requesting completions! " .. vim.inspect(lsp_result.err))
      goto continue
    end

    -- This server has sent 0 items
    if lsp_result.result == nil then
      goto continue
    end

    -- For each item we need to extract relevant information
    for _, completion in ipairs(lsp_result.result.items) do
      local item = {}

      if completion.label ~= nil then
        item.word = completion.label
      end

      if completion.insertText ~= nil then
        item.word = completion.insertText
      end

      if item.word == nil then
        goto continue
      end

      -- Filter out any items that don't match what we typed
      if not vim.startswith(item.word, base) then
        goto continue
      end

      item.kind = vim.lsp.protocol.CompletionItemKind[completion.kind]

      table.insert(result.words, item)
    end

    ::continue::
  end

  return result
end
```

This is already enough to give you basic semantic completion. You could go ahead and extend this to
include more / different information in the completion menu, or setup autocommands to display
documentation for the current item in a floating window, but those are details you can figure out
yourself.

If you have a slow language server you will notice that a completion request can block for
a substantial amount of time. To avoid this, we can make our requests asynchronously, and that's
what I want to show here as well.

If you read `:help ins-completion` carefully, you have noticed that during the first call to our
function we can return `-2` or `-3` as well, signalling that we will either supply completions later
(`-2`), or never (`-3`). We can use this to make async completion requests and exit our function
immediately, letting a callback function call `vim.fn.complete()` later to supply the actual
results. This means that we actually won't need either of our parameters, since we never get called
twice anyway.

```lua
local function omnifunc()
  local buffer = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buffer, method = "textDocument/completion" })

  if vim.tbl_isempty(clients) then
    -- Signal that we can't provide any completions
    return -3
  end

  local window = vim.api.nvim_get_current_win()
  local cursor_col = vim.api.nvim_win_get_cursor(window)[2]
  local line = vim.api.nvim_get_current_line():sub(1, cursor_col)
  local start_col = vim.fn.match(line, "\\k*$") + 1
  local base = line:sub(start_col)
  local completions = {}

  -- This will be called once our request is done
  local callback = function()
    vim.fn.complete(start_col, completions)
  end

  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_position_params(window, client.offset_encoding)

    -- Make an async request
    client.request("textDocument/completion", params, function(err, result)
      if err ~= nil then
        print("Error while requesting completions! " .. vim.inspect(err))
        return
      end

      if result == nil then
        print("No LSP completions.")
        return
      end

      local items = {}

      for _, completion in ipairs(result) do
        local item = {}

        --[[ same logic as earlier to extract information ]]

        table.insert(items, item)

        ::continue::
      end

      callback()
    end)
  end

  -- Signal that we want to stay in completion mode and supply actual results asynchronously
  return -2
end
```

This will be noticably faster and smoother.

I have [a much more complicated version of this](https://git.sr.ht/~alphakeks/.dotfiles/tree/4e50d8c69596cd72d97246c45aef0799c87b9a09/item/nvim/lua/alphakeks/lsp/completion.lua)
in [my dotfiles](https://git.sr.ht/~alphakeks/.dotfiles/tree/4e50d8c69596cd72d97246c45aef0799c87b9a09/item/nvim),
if you are interested.


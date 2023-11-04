# Finding your way around

Now that you got to know vim and understand the basics of using and configuring it, you should start
working on projects. You will only get better by doing, not by reading!

However, I do admit that navigating between files can be quite unintuitive, so I will discuss
different strategies here.

## netrw

vim ships with a builtin plugin called **netrw**. It's a file explorer, similar to the "file tree"
you might be used to from VSCode or similar. You can open netrw using various commands, one of which
is `:Explore` (or `:Ex` for short). It will open a buffer displaying the current directory
structure. It has a pretty ugly and useless banner at the top and unintuitive keybindings, and now
it's your best friend.

The basic controls should make sense; you navigate around using `j` and `k`, opening files or
directories with Enter, and going back up the file system by hitting Enter on the `../` directory.
But it can do more than that; for example `-` will also go up one directory, no matter where you
are! `%` will create a new file (don't ask me who came up with these, seriously), `d` will **not**
delete anything, but create a new directory. `D` will delete something though. `R` will rename aka.
move a file somewhere else. These should allow you for basic filesystem operations and navigation,
but if you think netrw sucks, I would totally agree with you!

## `:e`

`:edit` or `:e` for short will "edit" a path. This path may lead to a file or a directory, but it
doesn't need to actually exist. Once you opened a buffer using it you can save it using `:w` as
you're probably used to, but if the file is nested and the parent directories doesn't exist it will
throw an error. You can write the buffer to a file anyway by using `:w ++p`, this will create any
missing parents. `:e` is minimal and if you know where you want a file to go, it's probably what you
want to use to create that file. You can also make some convenience mappings that will insert your
current parent directory or something.

```vim
" `<C-r>=` will open the "expression register".
" `expand('%:p:h')` will expand to the parent directory of the current file.
nnoremap <Leader>e :e<C-r>=expand('%:p:h')<CR>/
```

## `:find`

This command is your friend when you don't exactly know the path to the file you wish to edit. By
default, similar to `:grep` it will use the standard `find` utility that's present on any *nix
system. Unlike `:grep` you can't actually change which command is used here, what a shame. The
arguments you pass to `:find` will be searched for in any of your `:help 'path'` directories. By
default this will be your current directory and maybe some system libraries. I personally have it
set to `.,**` which means "current directory" and "any sub-directories". The `**` is a glob
expression, which allows you to use `*` in `:find` commands. For example, if we have a very nested
file under `src/controllers/balls/ballsController.js` we can type `:find *ballsCont` and hit `<Tab>`
(or whatever your `:help 'wildchar'` is set to) to expand the query to a full path. I recommend
making a keymap for this as well:

```vim
" notice the lack of `<CR>` at the end, we want to still type a query after all
nnoremap <Leader>ff :find *
```

## `:b` and `:buffers`

The `:find` strategy is pretty good, but lets say you already opened all your files at least once,
what's a good way of switching between them? The answer is `:b`. It will take a buffer ID or name
(even just part of the name!) as an argument and open the best match. `:buffers` will display all
your current buffers to you. You can make a keymap that first displays all buffers and then prompts
you to open a specific one:

```vim
" notice the trailing space
nnoremap <Leader>fb :buffers<CR>:b 
```

Now you can hit your keymap, look at the buffer list, type something that roughly matches what you
want, hit enter, and boom you're there.

## Fuzzy Finders

Now I do admit that none of these seem impressive, especially if you're used to fuzzy finders that
will filter results in real time and allow more than just glob expressions. Both vim and neovim have
various plugins that implement fuzzy finders, the most popular of which is probably
[fzf.vim](https://github.com/junegunn/fzf.vim). It ships with
[fzf](https://github.com/junegunn/fzf) itself, and requires it to be installed. It will add
a `:FZF` command among other things, see their documentation for more details.

neovim has a great plugin called
[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) which pretty much every
neovim user uses nowadays. It's probably my favorite neovim plugin and I have [an entire document in
this repo dedicated to telescope specifically](./telescope.md).

## Moving between windows

This is a smaller point so I put it last here, but it is important. If you don't know yet, `:new`
and `:vnew`, as well as `:split` and `:vsplit` will open new **windows**, but how do you switch
between them? The short answer is: `<C-w>` followed by `h` / `j` / `k` / `l`. The long answer is:
read `:help CTRL-W` (you really should, there's a ton of `<C-w>` commands!).

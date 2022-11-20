-- ~/.config/nvim/lua/keymaps.lua

local map = vim.keymap.set
local o = { noremap = true, silent = true }

map('', '<Space>', '<Nop>', o) -- unbind space
vim.g.mapleader = ' ' -- set space as leader key

map('n', 'U', '<C-R>', o)
map('n', '<C-s>', '<cmd>w<CR>', o)
map('n', 'x', '"_x', o) -- delete without yanking
map('n', 'yw', 'yiw', o) -- yank a word from anywhere
map('n', 'dw', '"_diw', o) -- delete a word from anywhere without yanking
map('n', 'cw', '"_ciw', o) -- change a word from anywhere without yanking
map('n', 'cc', '"_cc', o) -- change line without yanking
map('v', 'c', '"_c', o) -- change selection without yanking
map('v', 'p', '"_dP', o) -- override selected word without yanking it
map('x', 'p', '"_dP', o)
map('n', 'ss', '<cmd>split<CR>', o)
map('n', 'sv', '<cmd>vsplit<CR>', o)
map('n', '<leader>r', '<cmd>%s/', { noremap = true })

-- line navigation / movement
map('n', 'j', 'gj', o)
map('n', 'k', 'gk', o)
map('n', 'J', 'V:m \'>+1<CR>gv=gv<ESC>', o)
map('n', 'K', 'V:m \'<-2<CR>gv=gv<ESC>', o)
map('v', 'J', ':m \'>+1<CR>gv=gv', o)
map('v', 'K', ':m \'<-2<CR>gv=gv', o)
map('x', 'J', ':m \'>+1<CR>gv=gv', o)
map('x', 'K', ':m \'<-2<CR>gv=gv', o)
map('n', '>', '>>', o)
map('n', '<', '<<', o)
map('x', '>', '>gv', o)
map('x', '<', '<gv', o)

-- buffer / window navigation
map('n', '<C-h>', '<C-w>h', o)
map('n', '<C-j>', '<C-w>j', o)
map('n', '<C-k>', '<C-w>k', o)
map('n', '<C-l>', '<C-w>l', o)
map('n', '<S-h>', '<cmd>bprevious<CR>', o)
map('n', '<S-l>', '<cmd>bnext<CR>', o)
map('n', '<C-w>', '<cmd>bdelete<CR>', o)
map('t', '<S-h>', '<cmd>bprevious<CR>', o)
map('t', '<S-l>', '<cmd>bnext<CR>', o)

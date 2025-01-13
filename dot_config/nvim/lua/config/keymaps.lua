-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

vim.g.copilot_no_tab_map = true
vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc')
vim.keymap.set({ 'i', 'n', 'v' }, '<C-K>', '<cmd>Lspsaga hover_doc<CR>')

-- Exit insert mode when using the bad habit of pressing the arrow keys, but still move
-- I am actively making things hard for-- well, me probably
vim.api.nvim_set_keymap("i", "<Up>", "<ESC>gk", {})
-- vim.api.nvim_set_keymap("i", "<Left>", "<ESC>h", {})
vim.api.nvim_set_keymap("i", "<Down>", "<ESC>gj", {})
-- vim.api.nvim_set_keymap("i", "<Right>", "<ESC>l", {})

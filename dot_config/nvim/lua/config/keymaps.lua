-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
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
-- vim.api.nvim_set_keymap("i", "<Right>", "<ESC>l", {})

-- I can't get rid of my ,-leaderkey. But I do wanna use space in the Helix-like space menu way... so yes!
---@diagnostic disable-next-line: assign-type-mismatch
vim.keymap.set('n', '<Space>f', function() Snacks.picker.files({ cwd = true }) end, { desc = "Open file picker (cwd)" })
vim.keymap.set('n', '<Space>g', function() Snacks.picker.grep() end, { desc = "Grep" })
vim.keymap.set('n', '<Space>b', function() Snacks.picker.buffers() end, { desc = "Open buffer picker" })
vim.keymap.set('n', '<Space>s', function() Snacks.picker.lsp_symbols() end, { desc = "Open symbol picker" })
vim.keymap.set('n', '<Space>S', function() Snacks.picker.lsp_symbols({ cwd = true }) end,
  { desc = "Open symbol picker (cwd)" })
vim.keymap.set('n', '<Space>?', function() Snacks.picker.commands() end, { desc = "Open command picker" })
vim.keymap.set('n', '<Space>r', function() Snacks.picker.resume() end, { desc = "Resume last search" })
vim.keymap.set('n', '<Space><Space>', function() Snacks.picker.resume() end, { desc = "Resume last search" })
vim.keymap.set('n', '<Space>c', "<cmd>normal gcc<CR>", { desc = "Comment line" })


vim.keymap.set('n', '<Space>\\', "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set('n', '<Space>-', "<cmd>split<CR>", { desc = "Horizontal split" })

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

vim.keymap.set("n", "<leader>C", vim.cmd("bd"), { desc = "Close Buffer" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-w>", vim.cmd("bd"), { desc = "Close buffer" })

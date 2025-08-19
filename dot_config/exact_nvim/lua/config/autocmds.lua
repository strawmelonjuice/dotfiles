-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
-- For now I see no reason to update the plugins everytime I open neovim -- UPDATE: I do now, constantly having notifs abt outdated stuff is annoying
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require "lazy".update({
      show = false,
    })
  end
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

local function open_nvim_tree(data)
  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not directory then
    return
  end

  -- create a new, empty buffer
  vim.cmd.enew()

  -- wipe the directory buffer
  vim.cmd.bw(data.buf)

  -- change to the directory
  vim.cmd.cd(data.file)

  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
-- For now I see no reason to update the plugins everytime I open neovim -- UPDATE: I do now, constantly having notifs abt outdated stuff is annoying
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require "lazy".update({
      show = false,
    })
  end
})

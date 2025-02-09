-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

-- // Set mapleader to ','
vim.cmd.let 'mapleader = ","'

-- // disable relative numbers
vim.opt.relativenumber = false

vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end
})

-- Options on Neovide

if vim.g.neovide then
  vim.notify_once("Neovide detected.")
  vim.g.neovide_transparency = 0.85
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_smooth_blink = true
end

-- When OS is Windows
if vim.fn.has "win32" == 1 then
  -- Disabled cuz slow
  -- vim.o.shell = "pwsh.exe"
  -- vim.o.shellcmdflag = "-command"
  -- vim.o.shellquote = "\""
  -- vim.o.shellxquote = ""
  vim.cmd("set nofsync")
end

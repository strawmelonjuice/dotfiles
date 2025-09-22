-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here

-- // Set mapleader to ','
vim.cmd.let 'mapleader = ","'

-- When OS is Windows
if vim.fn.has "win32" == 1 then
  -- Disabled cuz slow
  -- vim.o.shell = "pwsh.exe"
  -- vim.o.shellcmdflag = "-command"
  -- vim.o.shellquote = "\""
  -- vim.o.shellxquote = ""
  vim.cmd("set nofsync")
end

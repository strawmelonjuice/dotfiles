-- // For my own comfort I use the LazyVim distro instead of lazy.git
-- // This comes with some garbage that I do want to keep out.
-- // So, this file:

return {
  {
    "folke/noice.nvim",
    enabled = false
    },
    -- // Either bufferline or lualine came with LazyVim, no clue.
    {
  "akinsho/bufferline.nvim",
  enabled = false
},
{
    "lualine.nvim",
    enabled = false,
  },
  {
    "folke/zen-mode.nvim",
    enabled = false,
  }
}

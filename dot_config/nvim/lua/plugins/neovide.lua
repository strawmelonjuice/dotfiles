-- Options on Neovide

if vim.g.neovide then
  vim.notify_once("Neovide detected.")
  vim.g.neovide_transparency = 0.85
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_smooth_blink = true
end

return {}

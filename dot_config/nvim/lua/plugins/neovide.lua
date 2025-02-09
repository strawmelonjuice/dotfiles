-- Options on Neovide

if vim.g.neovide then
  vim.notify_once("Neovide detected.")
  vim.g.neovide_transparency = 0.85
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovid_mouse_cursor_icon = "i-beam"
  vim.g.neovide_cursor_vfx_particle_lifetime = 4.5
  vim.g.neovide_cursor_vfx_particle_density = 7.0
  vim.g.neovide_cursor_vfx_opacity = 200.0
end

return {}

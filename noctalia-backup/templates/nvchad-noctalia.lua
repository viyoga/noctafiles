-- Noctalia-generated NvChad theme — do not hand-edit, rerendered on every palette change
local M = {}

M.base_30 = {
  white = "{{colors.on_surface.default.hex}}",
  darker_black = "{{colors.shadow.default.hex}}",
  black = "{{colors.surface.default.hex}}",
  black2 = "{{colors.surface_container.default.hex}}",
  one_bg = "{{colors.surface.default.hex}}",
  one_bg2 = "{{colors.surface_variant.default.hex}}",
  one_bg3 = "{{colors.surface_container_low.default.hex}}",
  grey = "{{colors.surface_container_low.default.hex}}",
  grey_fg = "{{colors.on_surface_variant.default.hex}}",
  grey_fg2 = "{{colors.on_surface_variant.default.hex}}",
  light_grey = "{{colors.on_surface_variant.default.hex}}",
  red = "{{colors.error.default.hex}}",
  baby_pink = "{{colors.tertiary.default.hex}}",
  pink = "{{colors.tertiary.default.hex}}",
  line = "{{colors.surface_container.default.hex}}",
  green = "{{colors.terminal_normal_green.default.hex}}",
  vibrant_green = "{{colors.primary.default.hex}}",
  nord_blue = "{{colors.terminal_normal_blue.default.hex}}",
  blue = "{{colors.terminal_normal_blue.default.hex}}",
  yellow = "{{colors.terminal_normal_yellow.default.hex}}",
  sun = "{{colors.secondary.default.hex}}",
  purple = "{{colors.terminal_normal_magenta.default.hex}}",
  dark_purple = "{{colors.tertiary.default.hex}}",
  teal = "{{colors.terminal_normal_cyan.default.hex}}",
  orange = "{{colors.secondary.default.hex}}",
  cyan = "{{colors.terminal_normal_cyan.default.hex}}",
  statusline_bg = "{{colors.surface.default.hex}}",
  lightbg = "{{colors.surface_variant.default.hex}}",
  pmenu_bg = "{{colors.primary.default.hex}}",
  folder_bg = "{{colors.primary.default.hex}}",
}

M.base_16 = {
  base00 = "{{colors.surface.default.hex}}",
  base01 = "{{colors.surface_variant.default.hex}}",
  base02 = "{{colors.surface_container.default.hex}}",
  base03 = "{{colors.surface_container_low.default.hex}}",
  base04 = "{{colors.on_surface_variant.default.hex}}",
  base05 = "{{colors.on_surface.default.hex}}",
  base06 = "{{colors.on_surface.default.hex}}",
  base07 = "{{colors.on_surface.default.hex}}",
  base08 = "{{colors.error.default.hex}}",
  base09 = "{{colors.secondary.default.hex}}",
  base0A = "{{colors.terminal_normal_yellow.default.hex}}",
  base0B = "{{colors.terminal_normal_green.default.hex}}",
  base0C = "{{colors.terminal_normal_cyan.default.hex}}",
  base0D = "{{colors.terminal_normal_blue.default.hex}}",
  base0E = "{{colors.terminal_normal_magenta.default.hex}}",
  base0F = "{{colors.tertiary.default.hex}}",
}

M.type = "dark"

M = require("base46").override_theme(M, "noctalia")

return M

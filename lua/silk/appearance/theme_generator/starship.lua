local M = {}
local silk_util = require("silk.util")


function M.get_colors_as_table()
  local colors = {}

  colors["color_black"] = vim.g["terminal_ color0"]
  colors["color_red"] = vim.g["terminal_ color1"]
  colors["color_green"] = vim.g["terminal_ color2"]
  colors["color_yellow"] = vim.g["terminal_ color3"]
  colors["color_blue"] = vim.g["terminal_ color4"]
  colors["color_purple"] = vim.g["terminal_ color5"]
  colors["color_cyan"] = vim.g["terminal_ color6"]
  colors["color_white"] = vim.g["terminal_ color7"]


      "" [[
  [palettes.gruvbox_dark]
  color_fg0 = '#fbf1c7'
  color_bg1 = '#3c3836'
  color_bg3 = '#665c54'
  ]] ""
  return colors
end

function M.prompt_theme_generation()
  -- local colorscheme = M.get_colors_as_table()
  -- local theme = {}
  -- for setting_name, setting_value in ordered_pairs(colorscheme) do
  --   table.insert(theme, setting_name .. " " .. setting_value)
  -- end
  --
  -- silk_util.prompt_current_theme_name(function(theme_name)
  --   local theme_directory = silk_util.get_theme_directory("starship")
  --   local theme_file = theme_directory .. "/" .. theme_name .. ".toml"
  --   silk_util.write_file(theme_file, table.concat(theme, "\n"))
  -- end)
end

return M

local M = {}
local silk_util = require("silk.appearance.theme_generator.util")

local function color_from_syntax(name, type)
  type = type or "fg"
  local result = vim.api.nvim_eval('synIDattr(synIDtrans(hlID("' .. name .. '")), "' .. type .. '#")')
  if result == "" then
    return nil
  else
    return result
  end
end

-- TODO update to support new colors of new kitty versions
function M.scrape_current_colorscheme()
  local colors = silk_util.ordered_table({})

  colors.foreground = color_from_syntax("Normal", "fg")
  colors.background = color_from_syntax("Normal", "bg")
  colors.selection_foreground = color_from_syntax("Visual", "fg") or "none"
  colors.selection_background = color_from_syntax("Visual", "bg")

  colors.cursor = color_from_syntax("cursor", "bg") or colors.foreground
  colors.cursor_text_color = color_from_syntax("cursor", "fg") or colors.background

  colors.url_color = color_from_syntax("url")

  colors.active_border_color = color_from_syntax("TabLineSel")
  colors.inactive_border_color = color_from_syntax("VertSplit")
  colors.bell_border_color = color_from_syntax("Title")
  colors.visual_bell_color = "none"

  colors.wayland_titlebar_color = "system"
  colors.macos_titlebar_color = "system"

  colors.active_tab_foreground = colors.foreground
  colors.active_tab_background = silk_util.shade_color(colors.background, silk_util.is_light() and 12 or 25)
  colors.inactive_tab_foreground = color_from_syntax("Comment", "fg")
  colors.inactive_tab_background = silk_util.shade_color(colors.background, silk_util.is_light() and -12 or -25)
  colors.tab_bar_background = colors.background
  -- shade_color(colors.background, is_light() and -20 or -45)
  colors.tab_bar_margin_color = colors.inactive_border_color

  colors.mark1_foreground = colors.foreground
  colors.mark1_background = color_from_syntax("DiffAdd", "bg")
  colors.mark2_foreground = colors.foreground
  colors.mark2_background = color_from_syntax("DiffChange", "bg")
  colors.mark3_foreground = colors.foreground
  colors.mark3_background = color_from_syntax("DiffDelete", "bg")

  colors.bell_border_color = color_from_syntax("TextWarning")


  for i = 0, 255 do
    colors["color" .. i] = vim.g["terminal_color_" .. i]
  end

  local cleaned_colors = silk_util.ordered_table({})
  for setting_name, setting_value in silk_util.ordered_pairs(colors) do
    if setting_value ~= nil then
      cleaned_colors[setting_name] = string.lower(setting_value)
    end
  end
  return cleaned_colors
end

function M.prompt_theme_generation()
  local colorscheme = M.scrape_current_colorscheme()
  local theme = {}
  for setting_name, setting_value in silk_util.ordered_pairs(colorscheme) do
    table.insert(theme, setting_name .. " " .. setting_value)
  end

  silk_util.prompt_current_theme_name(function(theme_name)
    local theme_directory = silk_util.get_theme_directory("kitty")
    if theme_directory then
      silk_util.write_table_to_fs(vim.fs.joinpath(theme_directory, theme_name .. ".conf"), theme)
    end
  end)
end

return M

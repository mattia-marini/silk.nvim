local M = {}

local function ordered_pairs(t)
  local current_index = 0
  local function iter(t)
    current_index = current_index + 1
    local key = t[current_index]
    if key then
      return key, t[key]
    end
  end
  return iter, t
end

local function ordered_table(t)
  local current_index = 1
  local metatable = {}
  function metatable:__newindex(key, value)
    rawset(self, key, value)
    rawset(self, current_index, key)
    current_index = current_index + 1
  end

  return setmetatable(t or {}, metatable)
end

local function color_from_syntax(name, type)
  type = type or "fg"
  local result = vim.api.nvim_eval('synIDattr(synIDtrans(hlID("' .. name .. '")), "' .. type .. '#")')
  if result == "" then
    return nil
  else
    return result
  end
end

local function hex_to_rgb(color)
  local hex = color:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
end

local function alter(attr, percent)
  return math.floor(attr * (100 + percent) / 100)
end

local function shade_color(color, percent)
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then
    return "NONE"
  end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function is_light()
  return vim.opt.background:get() == "light"
end

function M.scrape_current_colorscheme()
  local colors = ordered_table({})
  colors.foreground = color_from_syntax("Normal", "fg")
  colors.background = color_from_syntax("Normal", "bg")
  for i = 0, 255 do
    colors["color" .. i] = vim.g["terminal_color_" .. i]
  end
  colors.cursor = color_from_syntax("cursor", "bg") or colors.foreground
  colors.cursor_text_color = color_from_syntax("cursor", "fg") or colors.background
  colors.url_color = color_from_syntax("url")
  colors.selection_foreground = color_from_syntax("Visual", "fg") or "none"
  colors.selection_background = color_from_syntax("Visual", "bg")
  colors.tab_bar_background = shade_color(colors.background, is_light() and -20 or -45)
  colors.active_tab_foreground = colors.foreground
  colors.active_tab_background = colors.background
  colors.inactive_tab_foreground = color_from_syntax("Comment", "fg")
  colors.inactive_tab_background = shade_color(colors.background, is_light() and -12 or -25)
  colors.active_border_color = color_from_syntax("TabLineSel")
  colors.inactive_border_color = color_from_syntax("VertSplit")
  colors.bell_border_color = color_from_syntax("TextWarning")

  local cleaned_colors = ordered_table({})
  for setting_name, setting_value in ordered_pairs(colors) do
    if setting_value ~= nil then
      cleaned_colors[setting_name] = string.lower(setting_value)
    end
  end
  return cleaned_colors
end

function M.prompt_theme_generation()
  local colorscheme = M.scrape_current_colorscheme()
  local config = { "# Put the following lines in your ~/.config/kitty/kitty.conf" }
  for setting_name, setting_value in ordered_pairs(colorscheme) do
    table.insert(config, setting_name .. " " .. setting_value)
  end

  require("silk.appearance.theme_generator.util").write_table_to_fs(
    vim.fn.input("Path to kitty config file: ", vim.fn.expand("~/.config/kitty/kitty.conf"), "file"),
    config
  )
end

return M

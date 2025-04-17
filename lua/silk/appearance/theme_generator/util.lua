local M = {}

function M.write_table_to_fs(path, table)
  -- Open output file for writing

  local file = io.open(path, "w")
  if not file then
    vim.notify("Could not open " .. path, vim.log.levels.ERROR)
    return
  end

  vim.notify("Writing file to " .. path, vim.log.levels.INFO)
  for _, line in ipairs(table) do
    file:write(line .. "\n")
  end

  file:close()
  vim.notify("Theme written to " .. path)
end

-- Reads a file and inserts the content of the table inside the
-- separator delimiter
function M.insert_table_content_in_file(path, table, separator)
  -- Open output file for writing

  vim.system()
  local file = io.open(path, "r")
  if not file then
    vim.notify("Could not open " .. path, vim.log.levels.ERROR)
    return
  end

  vim.notify("Writing file to " .. path, vim.log.levels.INFO)
  for _, line in ipairs(table) do
    file:write(line .. "\n")
  end

  file:close()
  vim.notify("Theme written to " .. path)
end

function M.prompt_current_theme_name(on_confirm)
  vim.ui.input({
      prompt = "Please insert a name for the theme: ",
      default = vim.g.colors_name or "",
    },
    function(input)
      print("\n")
      if input == nil or input == "" then
        M.prompt_current_theme_name(on_confirm)
      else
        on_confirm(input)
      end
    end
  )
end

-- Returns either the config directory or the config file
function M.get_config_location(tool)
  -- Fish config directory
  if tool == "fish" then
    local job = vim.system({ 'fish', '-c', 'echo $__fish_config_dir' }, { text = true }):wait()

    if not (job.code == 0 and #job.stdout > 0) then
      vim.notify("Could not get $__fish_config_dir", vim.log.levels.ERROR)
      return nil
    else
      return vim.fs.joinpath(job.stdout:gsub("\n", ""), "themes")
    end

    -- Kitty config directory
  elseif tool == "kitty" then
    if os.getenv("KITTY_CONFIG_DIRECTORY") then
      return os.getenv("KITTY_CONFIG_DIRECTORY")
    elseif os.getenv("XDG_CONFIG_HOME") then
      return vim.fs.joinpath(os.getenv("XDG_CONFIG_HOME"), "kitty", "themes")
    else
      return vim.fn.expand("~/.config/kitty/themes")
    end

    -- Starship config file
  elseif tool == "starship" then
    if os.getenv("$STARSHIP_CONFIG") then
      return os.getenv("$STARSHIP_CONFIG")
    else
      return vim.fn.expand("~/.config/starship.toml")
    end
  end
end

function M.ordered_pairs(t)
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

function M.ordered_table(t)
  local current_index = 1
  local metatable = {}
  function metatable:__newindex(key, value)
    rawset(self, key, value)
    rawset(self, current_index, key)
    current_index = current_index + 1
  end

  return setmetatable(t or {}, metatable)
end

function M.alter(attr, percent)
  return math.floor(attr * (100 + percent) / 100)
end

function M.shade_color(color, percent)
  local r, g, b = hex_to_rgb(color)
  if not r or not g or not b then
    return "NONE"
  end
  r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
  r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
  return string.format("#%02x%02x%02x", r, g, b)
end

function M.is_light()
  return vim.opt.background:get() == "light"
end

function M.hex_to_rgb(color)
  local hex = color:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
end

return M

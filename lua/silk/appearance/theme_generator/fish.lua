-- Define mapping of Fish variables to Neovim highlight groups
local fish_to_nvim = {
  fish_color_autosuggestion = { hi_group = "Comment" },
  fish_color_cancel = { hi_group = "Error" },
  fish_color_command = { hi_group = "Statement" },
  fish_color_comment = { hi_group = "Comment" },
  fish_color_cwd = { hi_group = "Directory" },
  fish_color_cwd_root = { hi_group = "Directory" },
  fish_color_end = { hi_group = "Delimiter" },
  fish_color_error = { hi_group = "Error" },
  fish_color_escape = { hi_group = "Special" },
  fish_color_history_current = { hi_group = "Search" },
  fish_color_host = { hi_group = "Identifier" },
  fish_color_host_remote = { hi_group = "Identifier" },
  fish_color_keyword = { hi_group = "Keyword" },
  fish_color_match = { hi_group = "IncSearch" },
  fish_color_normal = { hi_group = "Normal", attr = { "fg" } },
  fish_color_operator = { hi_group = "Operator" },
  fish_color_option = { hi_group = "Type" },
  fish_color_param = { hi_group = "Identifier" },
  fish_color_quote = { hi_group = "String" },
  fish_color_redirection = { hi_group = "Special" },
  fish_color_search_match = { hi_group = "Search" },
  fish_color_selection = { hi_group = "Visual" },
  fish_color_status = { hi_group = "ErrorMsg" },
  fish_color_user = { hi_group = "Constant" },
  fish_color_valid_path = { hi_group = "Underlined" },
  --
  fish_pager_color_completion = { hi_group = "Pmenu", attr = { fg = true } },
  fish_pager_color_selected_completion = { hi_group = "PmenuSel", attr = { fg = true } },
  fish_pager_color_secondary_completion = {
    hi_group = "Pmenu",
    attr = { fg = true },
    -- extra = { "--dim" }
  },
  --
  fish_pager_color_background = { hi_group = "Pmenu", attr = {} },
  fish_pager_color_selected_background = { hi_group = "PmenuSel", attr = { "bg" } },
  fish_pager_color_secondary_background = {
    hi_group = "Pmenu",
    attr = {},
  },
  --
  fish_pager_color_description = { hi_group = "Pmenu", attr = { fg = true } },
  fish_pager_color_selected_description = { hi_group = "PmenuSel", attr = { fg = true } },
  fish_pager_color_secondary_description = {
    hi_group = "Pmenu",
    attr = { fg = true },
    -- extra = { "--dim" }
  },
  --
  fish_pager_color_prefix = { hi_group = "Pmenu", attr = { fg = true }, extra = { "--underline", "--bold" } },
  fish_pager_color_selected_prefix = { hi_group = "PmenuSel", attr = { fg = true }, extra = { "--underline", "--bold" } },
  fish_pager_color_secondary_prefix = {
    hi_group = "Pmenu",
    attr = { fg = true },
    extra = { "--underline", "--bold" }
  },
  --
  fish_pager_color_progress = { hi_group = "StatusLine", attr = { fg = true } },
}

local function format_color(color)
  return string.format("%06x", color)
end

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- Function to convert Neovim highlight attributes to Fish-style options
local function format_attrs(hi_group, attr)
  local style = {}

  if hi_group.bg and (not attr or attr.bg) then table.insert(style, "--background=" .. format_color(hi_group.bg)) end
  if hi_group.bold and (not attr or attr.bold) then table.insert(style, "--bold") end
  if hi_group.italic and (not attr or attr.italic) then table.insert(style, "--italics") end
  if hi_group.reverse and (not attr or attr.reverse) then table.insert(style, "--reverse") end
  if hi_group.underline and (not attr or attr.underline) then table.insert(style, "--underline") end
  -- if attrs.standout then table.insert(parts, "--background") end -- rough match
  -- if attrs.strikethrough then table.insert(parts, "--dim") end   -- not exact

  return table.concat(style, " ")
end

function generate_theme()
  local rv = {}
  for fish_var, format in pairs(fish_to_nvim) do
    local hi_group = vim.api.nvim_get_hl(0, { name = format.hi_group, create = false })
    if hi_group then
      -- Fetching optional fg
      local fg = ""
      if not format.attr or format.attr.fg then
        if hi_group.fg then
          fg = format_color(hi_group.fg)
        end
      end

      -- Parseing additional formatting flags
      local flags = format_attrs(hi_group, format.attr)

      -- Parsing extra flags
      local extras = table.concat(format.extra or {}, " ")

      -- Constructing the Fish variable line
      local line = fish_var .. " " .. fg .. " " .. flags .. " " .. extras
      line = trim(line)

      table.insert(rv, line)
    else
      -- Inserting error line to indicate missing highlight group. This should happen
      table.insert(rv, fish_var .. " error\n")
    end
  end
  return rv
end

function generate_and_write_theme()
  local rv = generate_theme()
  table.insert(rv, 1, "# name: '" .. vim.g.colors_name .. "'")
  table.insert(rv, 2,
    "# preferred_background: " .. string.format("%06X", vim.api.nvim_get_hl(0, { name = "Normal" }).bg))
  table.insert(rv, 3, "")

  local job = vim.system({ 'fish', '-c', 'echo $__fish_config_dir' }, { text = true }):wait()
  if not (job.code == 0 and #job.stdout > 0) then
    vim.notify("Could not get $__fish_config_dir", vim.log.levels.ERROR)
    return
  end
  local fish_config_dir = job.stdout:gsub("\n", "") -- Remove trailing newline

  -- Open output file for writing
  local output_path = vim.fs.joinpath(fish_config_dir, "themes", vim.g.colors_name .. ".theme")
  vim.notify("Writing file to " .. output_path, vim.log.levels.INFO)

  local file = io.open(output_path, "w")
  if not file then
    vim.notify("Could not open " .. output_path, vim.log.levels.ERROR)
    return
  end

  for _, line in ipairs(rv) do
    file:write(line .. "\n")
  end

  file:close()
  vim.notify("Fish color export written to " .. output_path)
end

-- -- Get $__fish_config_dir from the environment
-- local fish_config_dir = os.getenv("__fish_config_dir")
-- if not fish_config_dir then
--   vim.notify("$__fish_config_dir is not set", vim.log.levels.WARN)
--   return
-- end
--
-- -- Open output file for writing
-- local output_path = fish_config_dir .. "/nvim_colors.fish"
-- local file = io.open(output_path, "w")
-- if not file then
--   vim.notify("Could not open " .. output_path, vim.log.levels.ERROR)
--   return
-- end



-- file:close()
-- vim.notify("Fish color export written to " .. output_path)

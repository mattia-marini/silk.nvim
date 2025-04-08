-- Define mapping of Fish variables to Neovim highlight groups
local fish_to_nvim = {
  fish_color_autosuggestion = "Comment",
  fish_color_cancel = "Error",
  fish_color_command = "Statement",
  fish_color_comment = "Comment",
  fish_color_cwd = "Directory",
  fish_color_cwd_root = "Directory",
  fish_color_end = "Delimiter",
  fish_color_error = "Error",
  fish_color_escape = "Special",
  fish_color_history_current = "Search",
  fish_color_host = "Identifier",
  fish_color_host_remote = "Identifier",
  fish_color_keyword = "Keyword",
  fish_color_match = "IncSearch",
  fish_color_normal = "Normal",
  fish_color_operator = "Operator",
  fish_color_option = "Type",
  fish_color_param = "Identifier",
  fish_color_quote = "String",
  fish_color_redirection = "Special",
  fish_color_search_match = "Search",
  fish_color_selection = "Visual",
  fish_color_status = "ErrorMsg",
  fish_color_user = "Constant",
  fish_color_valid_path = "Underlined",
  fish_pager_color_background = "Pmenu",
  fish_pager_color_completion = "PmenuSel",
  fish_pager_color_description = "Pmenu",
  fish_pager_color_prefix = "Search",
  fish_pager_color_progress = "StatusLine",
  fish_pager_color_secondary_background = "PmenuSbar",
  fish_pager_color_secondary_completion = "NonText",
  fish_pager_color_secondary_description = "Pmenu",
  fish_pager_color_secondary_prefix = "Search",
  fish_pager_color_selected_background = "PmenuSel",
  fish_pager_color_selected_completion = "PmenuSel",
  fish_pager_color_selected_description = "PmenuSel",
  fish_pager_color_selected_prefix = "PmenuSel"
}

-- Function to convert Neovim highlight attributes to Fish-style options
local function format_attrs(attrs)
  local parts = {}


  if attrs.bold then table.insert(parts, "--bold") end
  if attrs.italic then table.insert(parts, "--italics") end
  if attrs.reverse then table.insert(parts, "--reverse") end
  if attrs.underline then table.insert(parts, "--underline") end
  -- if attrs.standout then table.insert(parts, "--background") end -- rough match
  -- if attrs.strikethrough then table.insert(parts, "--dim") end   -- not exact

  return table.concat(parts, " ")
end

function generate_theme()
  local rv = {}
  for fish_var, nvim_group in pairs(fish_to_nvim) do
    local attrs = vim.api.nvim_get_hl(0, { name = nvim_group, create = false })
    if attrs then
      local hex = ""
      if attrs.fg then
        hex = string.format("%06x", attrs.fg)
      end

      local flags = format_attrs(attrs)

      local line = fish_var .. " " .. hex
      if #flags > 0 then
        line = line .. " " .. flags
      end

      -- if file then
      --   file:write(line .. "\n")
      -- end
      table.insert(rv, line)
    else
      -- if file then
      --   file:write(fish_var .. " error\n")
      -- end
      table.insert(rv, fish_var .. " error\n")
      -- print(fish_var .. " error\n")
    end
  end
  return rv
end

function generate_and_write_theme()
  local rv = generate_theme()

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

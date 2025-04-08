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
  vim.notify("Fish color export written to " .. path)
end

function M.prompt_current_theme_name(on_confirm)
  vim.ui.input({
      prompt = "Please insert a name for the theme: ",
      default = vim.g.colors_name or "",
    },
    function(input)
      print("\n")
      on_confirm(input)
    end
  )
end

function M.get_theme_directory(tool)
  if tool == "fish" then
    local job = vim.system({ 'fish', '-c', 'echo $__fish_config_dir' }, { text = true }):wait()

    if not (job.code == 0 and #job.stdout > 0) then
      vim.notify("Could not get $__fish_config_dir", vim.log.levels.ERROR)
      return nil
    else
      return vim.fs.joinpath(job.stdout:gsub("\n", ""), "themes")
    end
  elseif tool == "kitty" then
    if os.getenv("KITTY_CONFIG_DIRECTORY") then
      return os.getenv("KITTY_CONFIG_DIRECTORY")
    elseif os.getenv("XDG_CONFIG_HOME") then
      return os.getenv("XDG_CONFIG_HOME") .. "/kitty"
    else
      return vim.fn.expand("~/.config/kitty/themes")
    end
  end
end

return M

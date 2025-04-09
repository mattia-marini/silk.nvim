vim.api.nvim_create_user_command("SilkGenerate", function(args)
  require("silk.appearance.theme_generator." .. args.args).prompt_theme_generation()
end, {
  desc = "Generate a theme starting from the current colorscheme",
  complete = function(arglead, cmdargs)
    return { "kitty", "fish", "starship" }
  end,
  nargs = 1,
})


vim.api.nvim_create_user_command("SilkGo", function(args)
  require("silk.interaction.window").go_to_window(args.args)
end, {
  complete = function(arglead, cmdargs)
    return { "left", "right", "up", "down" }
  end,
  nargs = 1,
}
)

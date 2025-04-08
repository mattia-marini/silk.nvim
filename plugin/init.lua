vim.api.nvim_create_user_command("SilkGenerate", function(args)
  require("silk.appearance.theme_generator." .. args.args).prompt_theme_generation()
end, {
  desc = "Generate a theme starting from the current colorscheme",
  complete = function(arglead, cmdargs)
    return { "kitty", "fish", "starship" }
  end,
  nargs = 1,
})

return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      dimInactive = false,
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      statementStyle = { bold = true, italic = false },
      functionStyle = { italic = false },
      typeStyle = { italic = false },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")

      local colors = require("kanagawa.colors").setup()
      local float_colors = colors.theme.ui.float

      -- Global editor groups. Neo-tree's own groups are kept transparent in
      -- ui.lua, which re-applies after neo-tree defines them.
      require("config.transparent").clear_background({
        "Normal",
        "NormalNC",
        "SignColumn",
        "EndOfBuffer",
        "LineNr",
        "CursorLineNr",
        "FloatBorder",
        "FloatTitle",
      })

      if float_colors then
        vim.api.nvim_set_hl(0, "NormalFloat", {
          bg = float_colors.bg,
          fg = float_colors.fg,
        })
        vim.api.nvim_set_hl(0, "LspFloatWinNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "LspFloatWinBorder", {
          fg = float_colors.fg_border,
          bg = float_colors.bg,
        })
      end
    end,
  },
}

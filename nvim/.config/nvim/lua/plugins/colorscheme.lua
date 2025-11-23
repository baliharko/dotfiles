return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      dimInactive = false,
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")

      local colors = require("kanagawa.colors").setup()
      local float_colors = colors.theme.ui.float

      for _, group in ipairs({
        "Normal",
        "NormalNC",
        "SignColumn",
        "EndOfBuffer",
        "LineNr",
        "CursorLineNr",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeFloatNormal",
        "FloatBorder",
        "FloatTitle",
        "NeoTreeFloatBorder",
        "NeoTreeFloatTitle",
        "NeoTreeTitleBar",
      }) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if ok and hl then
          hl.bg = "none"
          hl.ctermbg = nil
          vim.api.nvim_set_hl(0, group, hl)
        end
      end

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

return {
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "Pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      debounce_delay = 135,
    },
  },
}

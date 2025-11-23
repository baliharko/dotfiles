return {
  {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "query", "c", "cpp", "javascript", "typescript", "rust" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      auto_install = true,
    },
  },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install parsers
      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "query",
        "c",
        "cpp",
        "go",
        "gomod",
        "gosum",
        "javascript",
        "typescript",
        "rust",
        "markdown",
        "markdown_inline",
        "json",
      })

      -- Enable treesitter highlighting for all supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}

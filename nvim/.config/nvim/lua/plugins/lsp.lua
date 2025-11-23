return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    opts = {},
  },
  {
    "saadparwaiz1/cmp_luasnip",
    lazy = true,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "buffer" } }
        ),
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local border = "rounded"
      local win = require("lspconfig.ui.windows")
      win.default_options.border = border

      local lsp = vim.lsp
      lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = border })
      lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, { border = border })
      vim.diagnostic.config({
        float = { border = border },
      })

      require("mason").setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "rust_analyzer", "eslint", "lua_ls" },
        handlers = {
          function(server)
            lspconfig[server].setup({
              capabilities = capabilities,
            })
          end,
          lua_ls = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  workspace = { checkThirdParty = false },
                  completion = { callSnippet = "Replace" },
                  diagnostics = { globals = { "vim" } },
                  telemetry = { enable = false },
                },
              },
            })
          end,
          clangd = function()
            lspconfig.clangd.setup({
              cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
              },
              root_dir = function(fname)
                return util.root_pattern(
                  "Makefile",
                  "configure.ac",
                  "configure.in",
                  "config.h.in",
                  "meson.build",
                  "meson_options.txt",
                  "build.ninja"
                )(fname)
                  or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname)
                  or util.find_git_ancestor(fname)
              end,
              capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } }),
              init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
              },
            })
          end,
        },
      })
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    main = "clangd_extensions",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "fatih/vim-go",
    ft = { "go", "gomod", "gosum", "gowork" },
  },
}

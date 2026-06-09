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
      local servers = { "clangd", "gopls", "rust_analyzer", "eslint", "lua_ls", "kotlin_language_server" }

      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Global defaults for all LSP servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Clangd: use system binary (native arm64), custom flags
      vim.lsp.config("clangd", {
        cmd = {
          "/usr/bin/clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        root_markers = {
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja",
          "compile_commands.json",
          "compile_flags.txt",
          ".git",
        },
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- Lua LS
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- Kotlin LS
      vim.lsp.config("kotlin_language_server", {
        root_markers = {
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          "settings.gradle.kts",
          ".git",
        },
        settings = {
          kotlin = {
            compiler = {
              jvmTarget = "17",
            },
          },
        },
      })

      vim.lsp.enable(servers)
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    main = "clangd_extensions",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
  },
}

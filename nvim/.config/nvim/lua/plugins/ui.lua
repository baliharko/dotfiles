return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        opts = {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              buftype = { "terminal", "quickfix" },
            },
          },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local argc = vim.fn.argc()
          if argc == 0 then
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
            return
          end

          if argc ~= 1 then
            return
          end

          local target = vim.fn.argv(0)
          if not target or target == "" then
            return
          end

          local absolute = vim.fn.fnamemodify(target, ":p")
          if vim.fn.isdirectory(absolute) == 0 then
            return
          end

          require("neo-tree.command").execute({ toggle = true, dir = absolute })
        end,
        once = true,
      })
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        hijack_netrw_behavior = "disabled",
      },
      window = {
        position = "float",
        mapping_options = {
          noremap = true,
          nowait = true,
        },
      },
    },
    config = function(_, opts)
      local groups = {
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeFloatNormal",
        "NeoTreeFloatBorder",
        "NeoTreeFloatTitle",
        "NeoTreeTitleBar",
        "FloatBorder",
        "FloatTitle",
      }

      local function hex(value)
        if type(value) == "number" then
          return string.format("#%06x", value)
        end
        return value
      end

      local function clear_background()
        for _, group in ipairs(groups) do
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
          if ok and hl then
            local attrs = {
              bg = "NONE",
              ctermbg = "NONE",
            }
            if hl.fg then
              attrs.fg = hex(hl.fg)
            end
            if hl.sp then
              attrs.sp = hex(hl.sp)
            end
            for _, key in ipairs({
              "bold",
              "italic",
              "underline",
              "undercurl",
              "underdouble",
              "underdashed",
              "underdotted",
              "strikethrough",
              "reverse",
              "nocombine",
              "standout",
            }) do
              if hl[key] ~= nil then
                attrs[key] = hl[key]
              end
            end
            if hl.ctermfg then
              attrs.ctermfg = hl.ctermfg
            end
            vim.api.nvim_set_hl(0, group, attrs)
          end
        end
      end

      local highlights = require("neo-tree.ui.highlights")
      local popups = require("neo-tree.ui.popups")

      local function ensure_border_highlight(border)
        if type(border) ~= "table" then
          return
        end

        local entries = {}
        if type(border.highlight) == "string" and border.highlight ~= "" then
          for _, item in ipairs(vim.split(border.highlight, ",", { trimempty = true })) do
            local colon = item:find(":")
            if colon then
              local from = item:sub(1, colon - 1)
              local to = item:sub(colon + 1)
              if from ~= "" and to ~= "" then
                entries[from] = to
              end
            elseif item ~= "" then
              entries.FloatBorder = item
            end
          end
        elseif border.highlight ~= nil then
          entries.FloatBorder = tostring(border.highlight)
        end

        if not entries.NormalFloat then
          entries.NormalFloat = highlights.FLOAT_NORMAL
        end
        if not entries.FloatBorder then
          entries.FloatBorder = highlights.FLOAT_BORDER
        end

        local ordered = vim.tbl_keys(entries)
        table.sort(ordered)
        local result = {}
        for _, key in ipairs(ordered) do
          table.insert(result, string.format("%s:%s", key, entries[key]))
        end
        border.highlight = table.concat(result, ",")
      end

      if not popups._transparent_border_patch then
        local original_popup_options = popups.popup_options
        popups.popup_options = function(...)
          local result = original_popup_options(...)
          ensure_border_highlight(result.border)
          return result
        end
        popups._transparent_border_patch = true
      end

      if not highlights._transparent_patch then
        local original_setup = highlights.setup
        highlights.setup = function(...)
          original_setup(...)
          clear_background()
        end
        highlights._transparent_patch = true
      end

      require("neo-tree").setup(opts)
      clear_background()
    end,
  },
}

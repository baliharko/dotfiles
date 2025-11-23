local map = vim.keymap.set
local lazy = require("lazy")

local function plugin_exec(plugin, fn)
  return function(...)
    lazy.load({ plugins = { plugin } })
    return fn(...)
  end
end

local telescope_modules
local neo_tree_command

local function with_telescope(callback)
  local function load_modules()
    if not telescope_modules then
      telescope_modules = {
        builtin = require("telescope.builtin"),
        telescope = require("telescope"),
        utils = require("telescope.utils"),
      }
    end
    return telescope_modules
  end

  return plugin_exec("telescope.nvim", function(...)
    return callback(load_modules(), ...)
  end)
end

local function with_neo_tree(callback)
  local function load_command()
    if not neo_tree_command then
      neo_tree_command = require("neo-tree.command")
    end
    return neo_tree_command
  end

  return plugin_exec("neo-tree.nvim", function(...)
    return callback(load_command(), ...)
  end)
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })

map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status (fugitive)" })

local telescope_mappings = {
  {
    "n",
    "<leader>pf",
    function(t)
      t.builtin.find_files({ find_command = { "rg", "--files", "--hidden", "-g", "!.git" } })
    end,
    "Find files (hidden)",
  },
  {
    "n",
    "<C-p>",
    function(t)
      t.builtin.git_files()
    end,
    "Git files",
  },
  {
    "n",
    "<leader>td",
    function(t)
      t.builtin.diagnostics()
    end,
    "Workspace diagnostics",
  },
  {
    "n",
    "<leader>tr",
    function(t)
      t.builtin.lsp_references()
    end,
    "LSP references",
  },
  {
    "n",
    "<leader>ps",
    function(t)
      t.builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end,
    "Grep prompt",
  },
  {
    "n",
    "<leader>pw",
    function(t)
      t.builtin.live_grep({ file_ignore_patterns = { "node_modules", ".git" } })
    end,
    "Live grep",
  },
  {
    "n",
    "<leader>fb",
    function(t)
      t.telescope.extensions.file_browser.file_browser({
        path = t.utils.buffer_dir(),
        select_buffer = true,
      })
    end,
    "File browser",
  },
}

for _, mapping in ipairs(telescope_mappings) do
  map(mapping[1], mapping[2], with_telescope(mapping[3]), { desc = mapping[4] })
end

map("n", "<leader>n", with_neo_tree(function(command)
  command.execute({ toggle = true, dir = vim.loop.cwd() })
end), { desc = "Toggle Neo-tree" })

map("n", "<leader>pv", with_neo_tree(function(command)
  command.execute({ toggle = true, dir = vim.loop.cwd(), position = "float" })
end), { desc = "Project view (Neo-tree)" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }
    local function buf_map(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
    end

    buf_map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    buf_map("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, "Hover info")
    buf_map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
    buf_map("n", "<leader>vd", vim.diagnostic.open_float, "Diagnostics float")
    buf_map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    buf_map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    buf_map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
    buf_map("n", "<leader>vrr", vim.lsp.buf.references, "References")
    buf_map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename symbol")
    buf_map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function(event)
    map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = event.buf, desc = "Switch source/header" })
  end,
})

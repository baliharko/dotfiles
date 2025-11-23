local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.wrap = false
opt.swapfile = false
opt.backup = false

local undo_dir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end
opt.undodir = undo_dir
opt.undofile = true

opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.scrolloff = 8
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.termguicolors = true
opt.updatetime = 50
opt.laststatus = 3
opt.clipboard = "unnamedplus"
opt.guicursor = ""

opt.fillchars = { eob = " " }
opt.signcolumn = "yes:1"

local fzf_path = "/opt/homebrew/opt/fzf"
if vim.fn.isdirectory(fzf_path) == 1 then
  vim.opt.rtp:append(fzf_path)
end

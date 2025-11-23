local augroup = vim.api.nvim_create_augroup("baliharko_user", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = "Briefly highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto comment continuation",
})

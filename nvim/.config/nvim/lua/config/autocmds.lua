local augroup = vim.api.nvim_create_augroup("baliharko_user", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.hl.on_yank()
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

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.go",
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf, async = false })
  end,
  desc = "gofmt Go files via gopls on save",
})

-- 'autoread' is on by default, but Neovim only notices a changed file when
-- something triggers a check. Nudge it on the events where the file on disk
-- is most likely to have moved on without us.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = augroup,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
  desc = "Check for files changed outside Neovim",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup,
  callback = function(args)
    vim.notify(vim.fn.fnamemodify(args.file, ":t") .. " changed on disk, buffer reloaded", vim.log.levels.WARN)
  end,
  desc = "Report buffers reloaded from disk",
})

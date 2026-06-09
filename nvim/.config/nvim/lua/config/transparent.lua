local M = {}

local function hex(value)
  if type(value) == "number" then
    return string.format("#%06x", value)
  end
  return value
end

-- Blank the background of the given highlight groups while preserving their
-- foreground colour and text attributes. Shared by the colorscheme (global
-- editor groups) and neo-tree (its own float groups) to keep a transparent
-- background without each maintaining its own copy of this logic.
function M.clear_background(groups)
  for _, group in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and hl then
      local attrs = { bg = "NONE", ctermbg = "NONE" }
      if hl.fg then
        attrs.fg = hex(hl.fg)
      end
      if hl.sp then
        attrs.sp = hex(hl.sp)
      end
      if hl.ctermfg then
        attrs.ctermfg = hl.ctermfg
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
      vim.api.nvim_set_hl(0, group, attrs)
    end
  end
end

return M

vim.api.nvim_create_user_command("PandocPDF", function()
  local input = vim.fn.expand("%")
  local output = vim.fn.expand("%:r") .. ".pdf"
  vim.cmd('silent !pandoc "' .. input .. '" -o "' .. output .. '"')
end, {})

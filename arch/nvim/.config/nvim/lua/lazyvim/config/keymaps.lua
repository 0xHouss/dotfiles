-- yanking
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to system clipboard" })

vim.keymap.set("n", "yA", function()
  local pos = vim.api.nvim_win_get_cursor(0) -- save current cursor position
  vim.cmd("normal! ggyG") -- yank whole file
  vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
end, { noremap = true, silent = true, desc = "Yank entire file" })

vim.keymap.set("n", "<leader>yA", function()
  local pos = vim.api.nvim_win_get_cursor(0) -- save current cursor position
  vim.cmd('normal! gg"+yG') -- yank whole file to clipboard
  vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
end, { noremap = true, silent = true, desc = "Yank entire file to system clipboard" })

-- lua
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute current lua file" })

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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

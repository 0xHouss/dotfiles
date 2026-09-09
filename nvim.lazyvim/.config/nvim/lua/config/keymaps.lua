-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- yanking to the system clipboard (the unnamed register stays local)
map({ "n", "v" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to System Clipboard" })
map({ "n", "v" }, "<leader>Y", '"+y$', { noremap = true, silent = true, desc = "Yank end of line to System Clipboard" })

map("n", "yA", function()
  local pos = vim.api.nvim_win_get_cursor(0) -- save current cursor position
  vim.cmd("normal! ggyG") -- yank whole file
  vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
end, { noremap = true, silent = true, desc = "Yank File Content" })

map("n", "<leader>yA", function()
  local pos = vim.api.nvim_win_get_cursor(0) -- save current cursor position
  vim.cmd('normal! gg"+yG') -- yank whole file to clipboard
  vim.api.nvim_win_set_cursor(0, pos) -- restore cursor position
end, { noremap = true, silent = true, desc = "Yank File Content to System Clipboard" })

-- paste over a selection without clobbering the unnamed register
map("v", "<leader>p", '"_dP', { noremap = true, desc = "Safe Paste" })

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({ "n", "v" }, "<C-y>", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", function()
  vim.lsp.buf.format({ async = false })
  vim.cmd("write")
end, { noremap = true, silent = true })

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

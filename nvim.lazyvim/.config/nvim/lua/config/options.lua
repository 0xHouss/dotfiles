-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.spelllang = { "en", "fr" }
vim.opt.conceallevel = 0

-- Keep Neovim's registers separate from the system clipboard; the explicit
-- "+ maps below are the only things that cross over.
vim.opt.clipboard = ""

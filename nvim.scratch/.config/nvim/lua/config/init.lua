require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.usercmds")

vim.cmd.colorscheme("matte-candy")

vim.filetype.add({
  extension = {
    prisma = "prisma",
  },
})

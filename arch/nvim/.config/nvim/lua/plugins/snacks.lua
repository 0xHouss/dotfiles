local exclude_dirs = {
  "node_modules",
  ".git",
  ".cache",
  ".vscode",
  ".next",
  ".idea",
  "dist",
  "build",
  "coverage",
}

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      exclude = exclude_dirs,
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = exclude_dirs,
        },
      },
    },
  },
}

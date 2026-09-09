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
  "target",
  "__pycache__",
  ".venv",
}

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
 ██████╗ ██╗  ██╗██╗  ██╗ ██████╗ ██╗   ██╗███████╗███████╗
██╔═████╗╚██╗██╔╝██║  ██║██╔═══██╗██║   ██║██╔════╝██╔════╝
██║██╔██║ ╚███╔╝ ███████║██║   ██║██║   ██║███████╗███████╗
████╔╝██║ ██╔██╗ ██╔══██║██║   ██║██║   ██║╚════██║╚════██║
╚██████╔╝██╔╝ ██╗██║  ██║╚██████╔╝╚██████╔╝███████║███████║
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝ ]],
      },
    },
    picker = {
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

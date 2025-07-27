return {
  "laytan/cloak.nvim",
  event = "BufReadPre",
  opts = {
    enabled = true,
    cloak_character = "•",
    highlight_group = "Comment",
    cloak_telescope = true,
    patterns = {
      {
        file_pattern = ".env*",
        cloak_pattern = "=.+",
      },
    },
  },
  keys = {
    {
      "<leader>uc",
      "<cmd>CloakToggle<CR>",
      desc = "Toggle Cloak",
    },
  },
}

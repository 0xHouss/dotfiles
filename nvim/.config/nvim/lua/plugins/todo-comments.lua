return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = false
  },
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                      desc = "Todo (Trouble)" },
    { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
  },
}

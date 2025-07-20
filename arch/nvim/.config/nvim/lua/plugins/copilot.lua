return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true, -- 👈 enables suggestions as you type
      keymap = {
        accept = "<C-l>", -- 👈 key to accept the suggestion
      },
    },
  },
}

return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  opts = {
    suggestion = {
      debug = false,
      enabled = true,
      auto_trigger = true, -- 👈 enables suggestions as you type
      keymap = {
        accept = "<C-l>", -- 👈 key to accept the suggestion
      },
    },
    panel = {
      enabled = false,
    },
  },
}

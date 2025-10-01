return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  opts = {
    suggestion = {
      auto_trigger = true, -- show suggestions as you type
      keymap = {
        accept = "<C-l>",  -- accept full suggestion
      },
    },
    panel = { enabled = false }, -- disable Copilot's completion panel
  }
}

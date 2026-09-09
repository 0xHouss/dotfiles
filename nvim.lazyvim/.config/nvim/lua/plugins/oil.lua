---@module 'oil'

-- Directory editing as a buffer. Loaded eagerly (not on `keys`) so it can
-- hijack netrw and own directory arguments -- `nvim .`, which the `n` shell
-- alias and the herdr/tmux editor panes all use.
return {
  "stevearc/oil.nvim",
  lazy = false,
  ---@type oil.SetupOpts
  opts = {
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["q"] = { "actions.close", mode = { "n", "v" } },
      ["<leader>o"] = { "actions.close", mode = { "n", "v", "i" } },
      ["-"] = { "actions.parent", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
    },
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open oil in parent directory" },
    { "<leader>o", "<CMD>Oil --float<CR>", desc = "Open floating oil" },
  },
}

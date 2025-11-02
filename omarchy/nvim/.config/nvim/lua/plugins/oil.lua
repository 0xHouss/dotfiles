---@module 'oil'

-- TODO: add extensions for git and diagnostics
return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  ---@type oil.SetupOpts
  opts = {
    -- default_file_explorer = false,
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = { "n", "v" } },
      ["q"] = { "actions.close", mode = { "n", "v" } },
      ["<leader>o"] = { "actions.close", mode = { "n", "v", "i" } },
      ["<C-l>"] = "actions.refresh",
      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
    },
    view_options = {
      show_hidden = true
    }
  },
  keys = {
    {
      "-",
      "<CMD>Oil<CR>",
      desc = "Open oil in parent directory"
    },
    {
      "<leader>o",
      "<CMD>Oil --float<CR>",
      desc = "Open floating oil in parent directory"
    }
  }
}

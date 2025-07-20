return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "zbirenbaum/copilot.lua", -- ensure copilot is loaded before this
  },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local copilot_ok, copilot = pcall(require, "copilot.suggestion")

    opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
      local col = vim.fn.col(".") - 1
      local line = vim.fn.getline(".")
      local char_before_cursor = line:sub(col, col)

      if copilot_ok and copilot.is_visible() then
        fallback() -- don’t accept copilot
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif col == 0 or char_before_cursor:match("%s") then
        fallback()
      else
        cmp.complete()
      end
    end, { "i", "s" })
  end,
}

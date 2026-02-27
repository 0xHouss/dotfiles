return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    -- event = { "BufReadPost", "BufNewFile" },
    -- cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "latex",
        "c",
        "diff",
        "html",
        "javascript",
        "java",
        "css",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "dockerfile",
        "xcompose",
        "luap",
        "markdown",
        "markdown_inline",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "prisma",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "BufReadPost",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    opts = {
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V',  -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        include_surrounding_whitespace = false,
      },
    },
    keys = {
      {
        "af",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Select outer function"
      },
      {
        "if",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Select inner function"
      },
      {
        "ac",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Select outer class"
      },
      {
        "ic",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Select inner class"
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}

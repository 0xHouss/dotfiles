return {

  {
    "williamboman/mason.nvim",
    opts = {},
    keys = {
      {
        "<leader>m",
        "<cmd>Mason<CR>",
        desc = "Mason"
      }
    }
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "ts_ls",
            "tailwindcss",
            "cssls",
            "html",
            "emmet_ls",
            "prismals",
            "pyright"
          },
          automatic_installation = true
        }
      },

      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "snacks.nvim",        words = { "Snacks" } },
          }
        }
      },

      'saghen/blink.cmp'
    },

    keys = {
      { "<leader>cr", function() vim.lsp.buf.rename() end,      desc = "Rename" },
      { "<leader>ca", function() vim.lsp.buf.code_action() end, desc = "Code Action", mode = { "n", "v" } },
    },
    opts = {
      servers = {
        ts_ls = {},
        tailwindcss = {},
        pyright = {}
      }
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end

      vim.diagnostic.config({
        virtual_text = true, -- ✅ show inline diagnostics
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end
  }
}

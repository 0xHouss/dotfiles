-- LSP tweaks on top of LazyVim's defaults.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- LazyVim turns inlay hints on by default; keep them off.
      -- <leader>uh still toggles them per-buffer when wanted.
      inlay_hints = { enabled = false },
    },
  },
}

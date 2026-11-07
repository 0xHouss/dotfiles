-- Omarchy's current theme. A real file rather than Omarchy's relative symlink:
-- ~/.config/nvim is stowed as one link into the repo, so that symlink's ../
-- path resolves inside the repo and finds nothing.
return dofile(vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua"))

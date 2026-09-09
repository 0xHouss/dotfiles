-- LazyVim defaults that aren't wanted here.
return {
  -- Buffer tab bar. <S-h>/<S-l> and [b/]b keep working via LazyVim's core
  -- keymaps (:bprevious/:bnext); only bufferline's own pin/pick/close-side
  -- commands go away with it.
  { "akinsho/bufferline.nvim", enabled = false },
}

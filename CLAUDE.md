# dotfiles

GNU Stow packages for an Omarchy (Arch + Hyprland) laptop. Every top-level
directory is one stow package whose inner path mirrors `$HOME`:
`bash/.bashrc` → `~/.bashrc`, `nvim/.config/nvim/` → `~/.config/nvim/`.

`CONTEXT.md` maps what each package holds and records the constraints the files
do not state themselves — which packages are deliberately unstowed, which
Omarchy plugins are clones of first-party ones, which values have to agree
across two files. Read it before editing a package for the first time in a
session, before adding a package, and before changing anything under
`omarchy/` or `hyprland/`.

## Editing

- Edit files here, not their `~` counterparts. Stowed paths are symlinks back
  into this repo, so the two are the same file; a `~` path that is a *real*
  file means that package is not stowed and editing it there changes nothing
  the repo tracks.
- Adding a file to an already-stowed package needs `stow <package>` again, run
  from the repo root (the shell alias supplies `-t ~`). Stow folds
  directories, so a package's entry in `~` is either one symlink to the
  package directory or a real directory holding per-file symlinks — both are
  normal.
- Documentation and reference snapshots that must stay out of `$HOME` are
  listed in the package's `.stow-local-ignore` (`omarchy/` has the example).

## Commits

`<package>: <lowercase imperative summary>` — `nvim: format rust with rustfmt`,
`omarchy: add the houss.workspaces bar widget`. The prefix is the package
directory name; keep one package per commit.

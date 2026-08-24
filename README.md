# dotfiles

Personal dotfiles & scripts for my terminal setup. 

## Stack
- Neovim + LazyVIM
- Starship
- btop
- eza
- git 
- scripts
- tmux
- yazi
- zsh

### Theme
- Tokyo Night Storm

## Machine-specific: Omarchy

The `omarchy/` package overrides files that collide with Omarchy's own
defaults (`.zshrc`, `zsh/aliases.zsh`, `btop.conf`) or that tmux would load
ahead of the shared package's `~/.tmux.conf` (Omarchy reads
`~/.config/tmux/tmux.conf`, and tmux always prefers `~/.tmux.conf` when both
exist). It also adds `zsh/omarchy.zsh`, a zsh port of Omarchy's default bash
toolkit (`tdl`, `a`/`c`/`cx`/`cy`, etc. — Omarchy only auto-loads that stuff
into bash), plus a `git/config` at Omarchy's XDG path with delta/editor
settings layered onto Omarchy's own (keeps its `gh` credential helpers), and
an `nvim/lua/config/autocmds.lua` with a CRLF-strip added on top of Omarchy's
version (not the stock LazyVim one in the shared `nvim/` package).

**On an Omarchy machine, stow `omarchy/` and skip the shared `tmux/`,
`btop/`, `zsh/`, and `git/` packages** — stowing them after (or instead of)
`omarchy/` will shadow these overrides. `nvim/`, `starship/`, `lazygit/`,
`eza/`, and `yazi/` are still shared as normal.



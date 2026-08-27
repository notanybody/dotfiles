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
version, and a `streamlink/config` (`player=mpv`) since this machine has
`mpv` rather than `vlc`, which streamlink otherwise looks for by default.

**On an Omarchy machine, stow `omarchy/` and skip the shared `tmux/`,
`btop/`, `zsh/`, and `git/` packages** — stowing them after (or instead of)
`omarchy/` will shadow these overrides. `nvim/`, `starship/`, `lazygit/`,
`eza/`, and `yazi/` are still shared as normal. `nvim/` deliberately does
**not** track `lua/plugins/obsidian.lua`, `lua/config/options.lua`,
`lazyvim.json`, or `lazy-lock.json` — Omarchy injects/manages these itself
(a `remote_clipboard` setup, the `neo-tree` extra, and Lazy's actual
installed-plugin lockfile), so a stale repo copy would silently overwrite
working machine state. `omarchy/` supplies its own `obsidian.lua` instead
(see below); the WSL machine does the same via `wsl/`.

## Machine-specific: WSL (Beelink)

Jack's Windows/WSL Ubuntu Beelink is still in daily use (travels alongside
the Omarchy laptop as a gaming PC) — it is **not** retired. `wsl/` currently
holds just `.config/nvim/lua/plugins/obsidian.lua`, pointing `obsidian.nvim`
at the WSL-side vault path `/mnt/j/obsidian-vault`. Stow `wsl/` alongside the
shared packages there; it only overrides the one file that needs a
machine-specific path.

### NAS mount (Omarchy)

Obsidian vault and other personal files live on a UGREEN NAS
(`192.168.68.55`, share `personal_folder`), mounted at `/mnt/nas` via
`/etc/fstab`:

```
//192.168.68.55/personal_folder /mnt/nas cifs credentials=/etc/samba/credentials-nas,uid=1000,gid=1000,iocharset=utf8,vers=3.0,noauto,x-systemd.automount,x-systemd.idle-timeout=60,_netdev 0 0
```

`noauto,x-systemd.automount` mounts on first access instead of blocking boot
if the NAS is off. The credentials file itself (`/etc/samba/credentials-nas`,
`username=`/`password=` lines, `chmod 600`) is **not** tracked here and must
be recreated by hand on any new machine — it's outside `$HOME` and holds a
plaintext password.

`omarchy/.config/nvim/lua/plugins/obsidian.lua` points `obsidian.nvim` at
`/mnt/nas/obsidian-vault` — this is a NAS-side mirror of the same vault the
WSL machine reaches directly at `/mnt/j/obsidian-vault` (see the WSL section
above).



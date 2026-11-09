# Framework Desktop Migration

One-time boot-day checklist for converting the incoming Framework desktop to
Linux as the new daily driver. The Beelink becomes a travel PC (basic tasks,
light gaming) afterward, not a decommission — don't wipe it as part of this.

Leaning **Omarchy** over Bazzite: this repo's `omarchy/` overlay already
covers the bring-up, and staying hands-on with pacman/AUR fits the
learning-Linux goal better than an atomic/Flatpak-first distro.

## 1. OS install & drivers
- [ ] Install Omarchy
- [ ] Confirm mesa/amdgpu + `vulkan-radeon` cover the Strix Halo APU — no
      vendor driver installer needed (unlike `amd-software-adrenalin` /
      `driverfusionfreesetup` on Windows)

## 2. Dotfiles bootstrap
- [ ] Install `stow`
- [ ] `git clone` this repo and `scripts` (github.com/notanybody/scripts)
- [ ] `git pull` before stowing anything
- [ ] Stow `omarchy/` — **skip** the shared `tmux/`, `btop/`, `zsh/`, `git/`
      packages, since `omarchy/` overrides them (see README for why)
- [ ] Stow `nvim/`, `starship/`, `lazygit/`, `eza/`, `yazi/` (shared, not
      overridden on Omarchy)
- [ ] Add a `desktop/` (or similarly named) machine-specific package if this
      box ends up needing its own overrides, same pattern as `wsl/`/`nas/`

## 3. Networking / self-hosted services
- [ ] Install Tailscale, log in — needed for Vaultwarden, Immich, Linkding,
      Ghostfolio, Actual Budget, AdGuard
- [ ] NAS mount: recreate `/etc/samba/credentials-nas` by hand (not tracked
      in git — plaintext password, lives outside `$HOME`), then the
      `/etc/fstab` CIFS line from the README's Omarchy section, mounted at
      `/mnt/nas`
- [ ] Point `obsidian.nvim` at `/mnt/nas/obsidian-vault` (reuse the
      `omarchy/` package's existing config — only needed if this becomes a
      second Omarchy-pattern machine with its own override package)
- [ ] SSH keys for `ssh nas` and GitHub

## 4. Dev tooling
- [ ] git, base-devel/gcc, node (via pacman or fnm/nvm) — no manual
      installers needed, unlike the Windows `.exe`/`.msi` downloads
- [ ] Docker Engine (not Docker Desktop — just the daemon + CLI)

## 5. Apps (Linux equivalents of `Downloads\setup-installers\`)
- [ ] Chrome (native/Flatpak)
- [ ] Discord (native package or Flatpak)
- [ ] Obsidian (AppImage/Flatpak, vault via NAS mount)
- [ ] VLC (native package)
- [ ] Chatterino (native Linux build)
- [ ] LocalSend (Flatpak/AppImage)
- [ ] Cider (Flatpak/AppImage build exists)
- [ ] Claude desktop — web app, or check for a current unofficial Linux build
- [ ] streamlink (pipx/pacman — used by the stream script project)
- [ ] mGBA (native package)
- [ ] Steam (native package)
- [ ] Capitaine cursors (native Linux theme — the Windows version was a port
      of this)
- [ ] FiraCode + JetBrains Mono Nerd Fonts (confirm already pulled in by
      dotfiles; install manually otherwise)

## 6. Hardware checks
- [ ] `memtest_vulkan` (cross-platform — grab the Linux build)
- [ ] `mprime` (Prime95's Linux CLI build)
- [ ] `stress-ng` + `s-tui` (no Linux OCCT — this is the substitute)
- [ ] `smartctl`/`gsmartcontrol` (replaces CrystalDiskInfo)
- [ ] `inxi -Fz` / `lm-sensors` + `hwinfo` (replaces HWiNFO)

## 7. Not needed on Linux
`amdcleanuputility`, `driverfusionfreesetup`, UGREEN NAS Windows client,
Docker *Desktop* specifically.

## 8. Unresolved
- [ ] `bm-14.1.0.exe` in the Windows installers folder — unidentified app,
      check what it is before assuming it's irrelevant

## 9. Project reconnects
- [ ] Strava dashboard, media downloader (queue.txt → yt-dlp → NAS), ghost
      animation script — pull from `scripts`/dotfiles, re-verify NAS paths
- [ ] Confirm `.zshrc` additions (incl. the parked ghost animation, if wired
      in by then) survive the move

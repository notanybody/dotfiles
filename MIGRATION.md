# Framework Desktop Migration

One-time boot-day checklist for converting the incoming Framework desktop to
Linux. **Decided: Omarchy** (not Bazzite — see rationale below). This box is
the daily driver and also runs the local AI stack (KoboldCpp + SwarmUI,
fronted by SillyTavern on the NAS — see `project_local_ai_stack` in Claude
memory for the full plan); occasional Steam, but Dojo already covers
dedicated gaming. The Beelink becomes a travel PC (basic tasks, light
gaming) afterward, not a decommission — don't wipe it as part of this.

**Why Omarchy over Bazzite:** Bazzite's two advantages — atomic rollback
and AI-stack convenience — don't actually apply here. Rollback safety
matters most for something unattended for months (the NAS, not a daily
driver you use and notice problems on yourself). The AI stack's KoboldCpp
backend uses Vulkan specifically to avoid needing ROCm, so there's no
ROCm-support edge for Bazzite to provide, and SillyTavern (the frontend)
runs on the NAS, not this box. Jack uses Omarchy as his real daily-driver OS
and Bazzite mainly as a console (Dojo, Big Picture boot) — reusing the
proven `omarchy/` dotfiles overlay fits both that instinct and the existing
setup. Tradeoff accepted: no reboot-to-rollback if an update breaks
something — recovery is manual (chroot from live USB / pacman downgrade),
same as the laptop already requires.

## 1. OS install & drivers
- [ ] Install Omarchy
- [ ] Confirm mesa/amdgpu + `vulkan-radeon` cover the Strix Halo APU — no
      vendor driver installer needed (unlike `amd-software-adrenalin` /
      `driverfusionfreesetup` on Windows). Vulkan is also what KoboldCpp
      needs for the AI stack, so this step covers both

## 2. Dotfiles bootstrap
- [ ] Install `stow`
- [ ] `git clone` this repo and `scripts` (github.com/notanybody/scripts)
- [ ] `git pull` before stowing anything
- [ ] Stow `omarchy/` — **skip** the shared `tmux/`, `btop/`, `zsh/`, `git/`
      packages, since `omarchy/` overrides them (see README for why)
- [ ] Stow `nvim/`, `starship/`, `lazygit/`, `eza/`, `yazi/` (shared, not
      overridden on Omarchy)
- [ ] Add a machine-specific package only if this box ends up needing its
      own overrides, same pattern as `wsl/`/`nas/`

## 3. Networking / self-hosted services
- [ ] Install Tailscale, log in — needed for Vaultwarden, Immich, Linkding,
      Ghostfolio, Actual Budget, AdGuard, and for reaching this box's
      KoboldCpp/SwarmUI from SillyTavern on the NAS
- [ ] NAS mount: recreate `/etc/samba/credentials-nas` by hand (not tracked
      in git — plaintext password, lives outside `$HOME`), then the
      `/etc/fstab` CIFS line from the README's Omarchy section, mounted at
      `/mnt/nas`
- [ ] Point `obsidian.nvim` at `/mnt/nas/obsidian-vault` (reuse the
      `omarchy/` package's existing config)
- [ ] SSH keys for `ssh nas` and GitHub
- [ ] Open KoboldCpp/SwarmUI ports on the `tailscale0` interface only —
      never port-forward (per `project_local_ai_stack`'s setup gaps)

## 4. Dev tooling
- [ ] git, base-devel/gcc, node (via pacman or fnm/nvm) — no manual
      installers needed, unlike the Windows `.exe`/`.msi` downloads
- [ ] Docker Engine (not Docker Desktop — just the daemon + CLI), only if
      needed beyond what the AI stack uses directly

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
- [ ] Steam (native package) — occasional use only; Dojo is the dedicated
      gaming machine
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
- [ ] Local AI stack: KoboldCpp + SwarmUI setup per `project_local_ai_stack`
      — separate, more involved bring-up once the hardware's confirmed
      working

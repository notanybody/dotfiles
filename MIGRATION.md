# Framework Desktop Migration

Boot-day checklist for setting up the Framework Desktop (Ryzen AI Max+ 395 /
64GB, own 2TB SSD) as an Omarchy daily driver that matches the Framework 13
laptop. The desktop also runs the local AI stack (KoboldCpp + SwarmUI, with
SillyTavern on the NAS; see `project_local_ai_stack` in Claude memory) and
gets Steam for occasional gaming. Dojo stays the dedicated gaming machine.
The Beelink becomes a travel PC. Don't wipe it as part of this.

Inventory last diffed against the laptop on **2026-11-13** (`pacman -Qqe` vs
Omarchy's package lists, `~/.local/bin`, webapps, hypr overrides, services).

**Why Omarchy over Bazzite:** Bazzite's two advantages, atomic rollback and
AI-stack convenience, don't apply here. Rollback matters most for a box
nobody watches for months (the NAS), not a daily driver. KoboldCpp uses
Vulkan to avoid needing ROCm, so Bazzite has no driver edge. The tradeoff
is accepted: no reboot-to-rollback, so recovery is manual (Omarchy's
limine/snapper snapshots, or chroot from a live USB), same as the laptop.

---

## 0. Before the weekend (on the laptop)
- [x] Fixed `/etc/pacman.conf`: removed the stray `EOF` line that the Cider
      repo heredoc left behind (2026-11-13)
- [x] `~/Projects/photo-badge` is now in git and pushed to
      github.com/notanybody/photo-badge (**private**, 2026-11-13)
- [x] Secrets saved and restore-tested (2026-11-13). None of these are in
      git:
  - `~/.age/`: age identity used for the encrypted NAS backups (Ghostfolio,
    Stash, Immich DB, etc.). Without it the desktop can't decrypt them
  - `~/.config/b2/`: B2 CLI account info (or just re-authorize `b2` with the
    key from Vaultwarden)
  - NAS SMB password for `/etc/samba/credentials-nas`
- [ ] Commit/push any open dotfiles, scripts, and claude-memory changes
- [ ] Have a wired Ethernet cable ready (the AI host should be wired)

## 1. OS install & first boot
- [ ] Install Omarchy with the **same username, `senchou`**. Claude's memory
      path (`~/.claude/projects/-home-senchou/`), the fstab `uid=1000`, and the
      Strata binds all assume it
- [ ] Mesa/amdgpu + `vulkan-radeon` cover the Strix Halo APU, so no vendor
      driver is needed. Check with `vulkaninfo --summary` (Vulkan is also
      what KoboldCpp uses)
- [ ] Write the specs memory: `cat /sys/class/dmi/id/product_name`, `lscpu`,
      `free -h`, `lsblk`. Check them against the order (395 / 64GB / 2TB)
- [ ] Hardware burn-in (Section 9) before you install much else

## 2. Packages (diffed from the laptop)
Everything below was installed explicitly on the laptop and is not part of
Omarchy's defaults:

```
sudo pacman -S --needed stow zsh yazi git-delta lazydocker \
  tailscale age bitwarden bitwarden-cli \
  google-chrome streamlink python-pipx \
  capitaine-cursors ttf-firacode-nerd \
  obs-studio kdenlive xournalpp \
  gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly \
  clang llvm dcraw bind wev
```

Notes:
- `dcraw` is for Strata's camera RAW previews. `bind` gives `dig` for
  AdGuard/DNS debugging. `wev` is a keycode viewer (it was used for the JIS
  remap; optional on a US keyboard)
- `clang`/`llvm` came in for the photo-badge / PlatformIO work. Skip them
  until you need them
- Omarchy already provides `docker`, `obsidian`, `mise`, `uv`, `gh`, node,
  and `claude` (via mise), so don't reinstall those

**Cider** (installed 2026-11-12) comes from its own pacman repo, not the AUR:
- [ ] Import and locally sign the repo key (fingerprint
      `A0CD6B993438E22634450CDD2A236C3F42A61682`, Cider Collective) per
      Cider's Linux docs
- [ ] Append the repo to `/etc/pacman.conf`, and **don't paste the closing
      `EOF`** this time:
      ```
      [cidercollective]
      SigLevel = Required TrustedOnly
      Server = https://repo.cider.sh/arch
      ```
- [ ] `sudo pacman -Sy cider`, then sign in to Apple Music. It sets itself as
      the handler for `music://`, `itms://`, and similar links automatically

**Non-pacman tools:**
- [ ] Strata file manager: run the release `install.sh` (check its sha256 and
      read it first). Pick launcher, default folder handler, Open file
      location, portal dialogs, and camera RAW. **Skip** the installer's
      Omarchy keybinds and udiskie (stow brings our binds). Then in Settings
      → Appearance, turn on Follow Omarchy
- [ ] `uv tool install b2` (B2 CLI for the off-site bucket)
- [ ] `pipx install platformio` (only when photo-badge work resumes)

**Optional, from the old Windows installers list** (not on the laptop; add
only if you miss them): Chatterino, LocalSend, mGBA, VLC (streamlink already
uses mpv), Steam (`sudo pacman -S steam`; needs multilib, which is already
on).

## 3. Dotfiles & config
- [ ] `gh auth login` (GitHub.com, **HTTPS**, log in with a web browser).
      `gh` comes with Omarchy, and Omarchy's git config already uses it as
      the credential helper, so no SSH key is needed for GitHub
- [ ] `mkdir ~/Projects`, then clone `dotfiles`, `scripts`, `claude-memory`,
      and `photo-badge` there over HTTPS (`gh repo clone notanybody/<repo>`)
- [ ] `git pull`, then stow from `~/Projects/dotfiles`:
      `omarchy nvim starship lazygit eza yazi scripts`
      **Skip** the shared `tmux btop zsh git` packages (`omarchy/` overrides
      them). **Never** stow `wsl` or `nas`. Also skip `ghostty`: it's the
      pre-Omarchy hardcoded Tokyo Night Storm config, it isn't stowed on the
      laptop, and it would override Omarchy's theme switching
- [ ] **Skip the `xkb` package.** The desktop keyboard is standard US, and
      the JIS remap is laptop-only. Leave `input.lua`'s `kb_layout` at
      Omarchy's default (don't copy the laptop's `us-jis` line)
- [ ] `chsh -s /usr/bin/zsh`, then log out and back in
- [ ] Re-link the `stream` script: `ln -s ~/Projects/scripts/stream
      ~/.local/bin/stream`
- [ ] `sudo pacman -S python-tqdm`: the NAS scripts' progress bar
      (`pacman_bar.py`) needs it, otherwise `organize-incoming` fails with
      `No module named 'tqdm'`. Use pacman, not pip (Arch blocks system pip)

**Hypr/terminal tweaks that are NOT in dotfiles** (made by hand on the
laptop; redo them here, or move them into `omarchy/` first):
- [ ] `hyprland.lua`: add `hl.env("XCURSOR_THEME", "capitaine-cursors-light")`
- [ ] Font: `omarchy-font-set "FiraCode Nerd Font"`, then set size **8** in
      ghostty (`font-size = 8`), alacritty, and kitty
- [ ] Theme: Tokyo Night (`omarchy-theme-set`)
- [ ] `input.lua`: the laptop's `natural_scroll` is touchpad-only, so it
      doesn't matter on a desktop unless you use a trackpad
- [ ] `monitors.lua`: the laptop uses scale 2 / GDK_SCALE 2 for its
      2880x1920 panel. **Set it for the desktop monitor instead** (`auto`, or
      1/1.5 depending on the panel)

## 4. SSH (NAS only) & Claude
GitHub stays on HTTPS through `gh` (Section 3). The SSH key below is only
for the NAS.
- [ ] `ssh-keygen -t ed25519` (a new key per machine; don't copy the
      laptop's)
- [ ] Recreate `~/.ssh/config` (not tracked):
      ```
      Host nas
        HostName 192.168.68.55
        User senchou
      ```
      then `ssh-copy-id nas` and check that `ssh nas` lands in zsh
- [ ] **Claude memory:** before the first `claude` run,
      `mkdir -p ~/.claude/projects/-home-senchou` then
      `ln -s ~/Projects/claude-memory ~/.claude/projects/-home-senchou/memory`
- [ ] `claude`, then log in. Check that it sees MEMORY.md

## 5. Networking & NAS
- [ ] `sudo systemctl enable --now tailscaled`, `sudo tailscale up`, then
      approve the node in the admin console. Consider turning off key expiry
      for this node (it's a server for the AI stack)
- [ ] NAS mount: create `/etc/samba/credentials-nas` by hand
      (`username=`/`password=`, `chmod 600`), add **both** CIFS lines from the
      README (`personal_folder` + `stash`) to `/etc/fstab`,
      `sudo mkdir -p /mnt/nas/senchou /mnt/nas/stash`, then
      `sudo systemctl daemon-reload && sudo systemctl restart remote-fs.target`.
      Check with `ls /mnt/nas/senchou/obsidian-vault /mnt/nas/stash`
- [ ] File-picker bookmarks (not stowed): append to `~/.config/gtk-3.0/bookmarks`
      `file:///mnt/nas/senchou nas` and `file:///mnt/nas/stash stash`
- [ ] Obsidian app: open the vault at `/mnt/nas/senchou/obsidian-vault`
      (`obsidian.nvim` already points there via `omarchy/`)
- [ ] Restore `~/.age/` from Vaultwarden/USB (`chmod 700`), and set up `b2`
      auth if you need it on this box
- [ ] Wired Ethernet. Optionally give it a DHCP reservation on the Deco

## 6. Apps & logins
- [ ] Chrome: sign in to sync (brings extensions, including Linkding's).
      Bitwarden desktop + browser extension, pointed at
      `vault.tail90599c.ts.net` (YubiKey)
- [ ] `bw config server https://vault.tail90599c.ts.net` for bitwarden-cli
- [ ] Webapps (SUPER+SPACE, Install Web App, or `omarchy-webapp-install`).
      These were added by hand on the laptop:
  - Actual: `https://actual.tail90599c.ts.net`
  - Ghostfolio: `https://ghostfolio.tail90599c.ts.net`
  - linkding: `https://linkding.tail90599c.ts.net`
  - Proton Mail: `https://mail.proton.me`
  - Discord: `https://discord.com/channels/@me`
  - Tailscale: `https://login.tailscale.com/admin/machines`
  - DressMyRun: `http://dressmyrun.com`
  - Check the SUPER+SHIFT+D (Discord) and SUPER+SHIFT+L (Linkding)
    binds; they come from the stowed `bindings.lua` and match on
    `chrome-<site>`
- [ ] Logins: Discord, Cider/Apple Music, Proton, Chrome, Obsidian (if
      synced), OBS settings (re-create scenes by hand)

## 7. Desktop-only: AI host prep
- [ ] Turn off suspend for this box (hypridle / `omarchy` idle settings), or
      set up Wake-on-LAN from the NAS
- [ ] Firewall is **ufw** on Omarchy (not firewalld). Open the AI ports on
      Tailscale only, e.g.
      `sudo ufw allow in on tailscale0 to any port 5001 proto tcp` (KoboldCpp)
      and `7801` (SwarmUI). Never port-forward on the router
- [ ] Give the iGPU up to ~48GB in BIOS/UMA settings, per the AI stack plan
- [ ] KoboldCpp + SwarmUI bring-up per `project_local_ai_stack`. That's a
      separate session once the hardware checks pass

## 8. Project reconnects
- [ ] Strava dashboard, media downloader, ghost animation: pull from
      `scripts`/dotfiles and re-check the NAS paths. Recreate any `.venv`
      with `uv venv` / `sv`
- [ ] photo-badge (cloned in Section 3): `pipx install platformio`. The first `pio run` rebuilds
      `.pio/` (~98MB of toolchains, gitignored). Flashing goes through
      `/dev/ttyACM0`, so add yourself to `uucp` if it isn't already set
      (the laptop has it)
- [ ] `stream`: check that streamlink plays through mpv (`omarchy/` stows
      `streamlink/config`)

## 9. Hardware checks
- [ ] `memtest_vulkan` (Linux build): VRAM/unified memory
- [ ] `stress-ng` + `s-tui`: CPU/thermals (stand-in for OCCT). Watch the
      Noctua fan curve
- [ ] `mprime` (Prime95 CLI) for a longer soak, if you want one
- [ ] `smartctl -a /dev/nvme0` (`smartmontools`): the new 2TB SSD
- [ ] `inxi -Fz`, `sensors` (`lm_sensors`): full hardware summary

## 10. Not needed on Linux
`amdcleanuputility`, `driverfusionfreesetup`, AMD Adrenalin, UGREEN NAS
Windows client, Docker Desktop, `bm-14.1.0.exe` (BenchMate, a Windows-only
benchmark validator; Section 9 covers burn-in instead).

## 11. Unresolved
- [ ] Desktop monitor resolution, for the `monitors.lua` scale (check it on
      first boot with `hyprctl monitors`)

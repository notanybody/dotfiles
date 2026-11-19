# Framework Desktop Migration

Checklist for setting up the Framework Desktop (Ryzen AI Max+ 395 / 64GB,
own 2TB SSD) as an Omarchy daily driver that matches the Framework 13
laptop. The desktop also runs the local AI stack (KoboldCpp + SwarmUI, with
SillyTavern on the NAS; see `project_local_ai_stack` in Claude memory) and
gets Steam for occasional gaming. Dojo stays the dedicated gaming machine.
The desktop replaces the Beelink on the desk KVM; the Beelink becomes a
travel PC. Don't wipe it as part of this.

**Status:** arrived and built 2026-11-19; migration started 2026-11-19.
Inventory last diffed against the laptop on **2026-11-19**
(`pacman -Qqe` vs Omarchy's package lists, `~/.local/bin`, webapps, hypr
overrides, services).

**Why Omarchy over Bazzite:** Bazzite's two advantages, atomic rollback and
AI-stack convenience, don't apply here. Rollback matters most for a box
nobody watches for months (the NAS), not a daily driver. KoboldCpp uses
Vulkan to avoid needing ROCm, so Bazzite has no driver edge. The tradeoff
is accepted: no reboot-to-rollback, so recovery is manual (Omarchy's
limine/snapper snapshots, or chroot from a live USB), same as the laptop.

**Day-1 reference:** until Section 4, read this from the laptop
(`cat ~/Projects/dotfiles/MIGRATION.md`) or on GitHub (public repo, no login
needed, opens in the desktop's Chromium too):
github.com/notanybody/dotfiles/blob/master/MIGRATION.md. Tick boxes on the
laptop and push now and then so progress survives a multi-day setup.

**Flow:** 0 prep → 1 install + firmware → 2 burn-in → 3 packages →
4 dotfiles → 5 SSH & Claude → 6 network & NAS → 7 apps → 8 AI host →
9 project reconnects.

---

## 0. Before it arrives (on the laptop)
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
- [x] Built the **`desktop/` stow package** (2026-11-15; same pattern as `wsl/`/`nas/`):
      `desktop/.config/hypr/monitors.lua` with the layout from Section 4,
      `desc:` placeholders included. **Only `monitors.lua`.** Fonts and the
      cursor line can't be stowed safely: `omarchy-font-set` runs
      `sed -i` on the terminal configs, which replaces a stow symlink with a
      plain file. They stay as manual steps in Section 4
- [x] Check the Framework Desktop's rear ports and your cables so the KVM's
      **DisplayPort** and **HDMI** inputs both connect directly (avoid
      adapters; one can cap refresh) (2026-11-19)
- [ ] Have a wired Ethernet cable ready (the AI host should be wired)
- [x] Have an Omarchy USB installer ready (fresh ISO written 2026-11-19)
- [x] **When it ships:** re-run the inventory diff (compare
      `pacman -Qqe` against `/usr/share/omarchy/install/*.packages`, and
      check `~/.local/bin` and `~/.local/share/applications`) and fold any
      new installs into Section 3 (2026-11-19: added `solaar`; `esptool`
      left off, it's Cardputer-only)
- [ ] The night before: commit/push any open dotfiles, scripts, and
      claude-memory changes

## 1. OS install & firmware
- [x] BIOS (F2): **iGPU Memory Config = Auto, Memory Size = minimum
      (0.5GB), left as-is** (decided 2026-11-19). A fixed 48GB carve-out
      would leave Linux ~16GB all the time. Instead the GPU borrows system
      RAM on demand (GTT), and the limit is raised with a kernel option in
      Section 8. No BIOS trips to change it later
- [x] BIOS → Security → Secure Boot → **Disabled**. The Omarchy ISO
      isn't signed, so with it on the USB fails with "EFI USB Device boot
      failed" (2026-11-19)
- [x] Install Omarchy with the **same username, `senchou`**, hostname
      **`omarchy-desktop`** (the laptop is `omarchy` locally,
      `omarchy-laptop` on the tailnet) (2026-11-19). Claude's memory
      path (`~/.claude/projects/-home-senchou/`), the fstab `uid=1000`, and the
      Strata binds all assume it
- [ ] Plug in Ethernet, then `omarchy-update`
- [x] Firmware (2026-11-19: BIOS already latest; only Secure Boot dbx
      updates offered, skipped since Secure Boot is off): `sudo pacman -S fwupd` first (Omarchy doesn't ship it;
      found 2026-11-19), then `fwupdmgr refresh && fwupdmgr get-updates`, then
      `fwupdmgr update` (Framework ships BIOS updates through LVFS). Reboot
      if it asks. If the BIOS update resets settings, re-check UMA
- [ ] Mesa/amdgpu + `vulkan-radeon` cover the Strix Halo APU, so no vendor
      driver is needed. Check with `vulkaninfo --summary` (Vulkan is also
      what KoboldCpp uses)
- [ ] Write the specs memory: `cat /sys/class/dmi/id/product_name`, `lscpu`,
      `free -h`, `lsblk`. Check them against the order (395 / 64GB / 2TB)

## 2. Burn-in (before installing much else)
- [ ] Tools: `sudo pacman -S stress-ng s-tui smartmontools` (`lm_sensors`
      and `inxi` come with Omarchy), `yay -S mprime-bin`, and
      **memtest_vulkan** as the Linux release binary from its GitHub page
      (it isn't in the AUR; put it in `~/.local/bin`)
- [ ] `inxi -Fz` and `sensors`: full hardware summary and baseline temps
- [ ] `smartctl -a /dev/nvme0`: the new 2TB SSD (no errors, health OK)
- [ ] `memtest_vulkan`: VRAM/unified memory. Let it run at least a few
      minutes with zero errors
- [ ] `stress-ng` with `s-tui` watching: CPU/thermals (stand-in for OCCT).
      Watch the Noctua fan curve
- [ ] `mprime` for a longer soak, if you want one

## 3. Packages (diffed from the laptop)
Everything below was installed explicitly on the laptop and is not part of
Omarchy's defaults, plus Steam:

```
sudo pacman -S --needed stow zsh yazi git-delta lazydocker \
  tailscale age bitwarden bitwarden-cli \
  google-chrome streamlink python-pipx python-tqdm \
  capitaine-cursors ttf-firacode-nerd \
  obs-studio kdenlive xournalpp \
  gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly \
  mgba-qt qt5-wayland syncthing steam glow \
  dcraw bind solaar
```

Notes:
- `python-tqdm`: the NAS scripts' progress bar (`pacman_bar.py`) needs it,
  otherwise `organize-incoming` fails with `No module named 'tqdm'`. Use
  pacman, not pip (Arch blocks system pip)
- `qt5-wayland`: mgba-qt is built on Qt5, and Omarchy doesn't ship Qt5's
  Wayland plugin. Without it mGBA warns
  `Could not find the Qt platform plugin "wayland"` and falls back to
  XWayland (blurry UI)
- `steam` needs multilib, which Omarchy already enables. When it asks
  which Vulkan driver to use, pick `vulkan-radeon` (AMD)
- `glow` renders Markdown in the terminal (`glow MIGRATION.md`, or just
  `glow` in a folder to browse)
- `solaar` configures the Logitech MX Master 4 (DPI, SmartShift, thumb
  wheel, buttons, haptics). See the mouse step in Section 4
- `dcraw` is for Strata's camera RAW previews. `bind` gives `dig` for
  AdGuard/DNS debugging
- Left off on purpose: `wev` (keycode viewer, only needed for the laptop's
  JIS remap), `clang`/`llvm` (only for photo-badge/PlatformIO work; add
  them when that resumes), and `esptool` (Cardputer flashing; add it if
  that moves to the desktop)
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
- [ ] `pipx install platformio`: only when photo-badge work resumes

**Optional** (not on the laptop; add only if you miss them): Chatterino,
LocalSend, VLC (streamlink already uses mpv).

## 4. Dotfiles & config
- [ ] `gh auth login` (GitHub.com, **HTTPS**, log in with a web browser).
      `gh` comes with Omarchy, and Omarchy's git config already uses it as
      the credential helper, so no SSH key is needed for GitHub
- [ ] `mkdir ~/Projects`, then clone `dotfiles`, `scripts`, `claude-memory`,
      and `photo-badge` there over HTTPS (`gh repo clone notanybody/<repo>`)
- [ ] Move Omarchy's default monitor file out of the way first, or stow
      will refuse to overwrite it:
      `mv ~/.config/hypr/monitors.lua ~/.config/hypr/monitors.lua.omarchy`
- [ ] Stow from `~/Projects/dotfiles`:
      `stow omarchy desktop nvim starship lazygit eza yazi scripts ghostty`
  - **Then** `stow --ignore='\.zshrc' zsh`. `omarchy/.zshrc` sources
    `~/.config/zsh/aliases.zsh`, which lives **only** in the shared `zsh/`
    package (`gp`, `gl`, `za`, `mdv`, `$SCRIPTS`, the NAS functions...).
    `--ignore` skips `zsh/.zshrc`, which would conflict with `omarchy/`'s.
    Check with `ls -la ~/.config/zsh/` (both files should be links)
  - **Skip** `tmux btop git` (`omarchy/` overrides them)
  - `ghostty` holds only `overrides.conf` (stowed as a file link next to
    Omarchy's own `config`). It does nothing until the include line in
    **Manual tweaks** below is added
  - **Never** stow `ghostty-mac` on Omarchy (the Mac's old Tokyo Night Storm
    `config.ghostty`; Ghostty auto-loads that filename, which would
    override Omarchy's theme switching)
  - **Skip** `xkb` (the desktop keyboard is standard US; the JIS remap is
    laptop-only)
  - **Never** stow `wsl` or `nas`
- [ ] `chsh -s /usr/bin/zsh`, then log out and back in
- [ ] Re-link the `stream` script: `ln -s ~/Projects/scripts/stream
      ~/.local/bin/stream`

**Monitors** (`desktop/` package): two Gigabytes through an **iDock B10
KVM**, shared with the work laptop:

| Monitor | Native | Through KVM | Port | Position | Scale |
|---|---|---|---|---|---|
| M27UA (27" 4K) | 3840x2160 | 160Hz | DisplayPort | left | 1.5 |
| M27Q (27" 1440p) | 2560x1440 | 144Hz | HDMI | right | 1 |

Both are the same **2560x1440 logical** size, so they line up exactly and
the mouse doesn't jump between them (on Windows it does, because Windows
lays monitors out in physical pixels). Hyprland positions use logical
pixels, so the M27Q starts at x=2560. Never use the M27Q's 3840x2160 mode:
the panel just downscales it, which makes text soft.

The `desktop/` package's `monitors.lua` (built in Section 0):
```lua
local omarchy_gdk_scale = 1
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Match by description, not connector: connectors can rename through
-- the KVM. Use the exact text from `hyprctl monitors all`.
hl.monitor({ output = "desc:<M27UA description>", mode = "3840x2160@160", position = "0x0",    scale = 1.5 })
hl.monitor({ output = "desc:<M27Q description>",  mode = "2560x1440@144", position = "2560x0", scale = 1 })
-- Fallback for anything else plugged in later
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
```
- [ ] `hyprctl monitors all`: copy each monitor's `description:` into the
      two placeholders. The file is a symlink into the repo, so commit the
      change from `~/Projects/dotfiles`
- [ ] Move the mouse along the shared edge, top to bottom. There should be
      no jump
- [ ] `hyprctl monitors` shows 160 and 144 Hz. If the M27UA falls back to
      60Hz, the DP cable or the KVM's DP port is the limit
- [ ] XWayland apps (some Electron/older apps) may look small on the 4K at
      GDK_SCALE 1. That's expected; it keeps them sharp
- [ ] **KVM switch test:** with a few windows open on each monitor, switch
      to the work laptop and back. Omarchy's per-monitor workspaces
      (`monitor-workspaces.lua`, matched by make/model/serial) should put
      everything back where it was. Note whether the B10 keeps the monitors
      "connected" while you're switched away, or drops them
- **Stow hazards:** two Omarchy tools break the `monitors.lua` link:
  - The monitor-scaling menu (`omarchy-hyprland-monitor-scaling`) replaces
    the link with a plain file. Change scale in the repo file instead
  - `omarchy-refresh-hyprland` copies Omarchy's defaults *through* the link,
    into the repo. If `git status` shows `monitors.lua` changed after an
    Omarchy update, `git restore` it

**Manual tweaks** (not stowable; see Section 0):
- [ ] `~/.config/hypr/hyprland.lua`: add
      `hl.env("XCURSOR_THEME", "capitaine-cursors-light")`, then tell GTK
      apps (Chrome, file pickers) too, or they keep the default cursor:
      `gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors-light`.
      Size stays the default 24. Takes effect after a re-login
- [ ] Font: `omarchy-font-set "FiraCode Nerd Font"` (sets the family in
      every terminal), then set `font-size = 10` in `~/.config/ghostty/config`.
      Ghostty only reads its own config and can't follow a system font size,
      so this is a hand edit. The other terminals aren't used, so leave
      their sizes alone
- [ ] Ghostty overrides (lean-out, 2026-11-15): in `~/.config/ghostty/config`,
      add this under the theme `config-file` line:
      ```
      # Personal overrides (tracked in dotfiles; loads last, wins over everything)
      config-file = ?"overrides.conf"
      ```
      `overrides.conf` (from the `ghostty` package) turns off toasts, desktop
      notifications and the bell, sets padding to 6, and unbinds Ghostty's
      tab/split/fullscreen keys. Reload with Ctrl+Shift+, then check
      `ghostty +list-keybinds | wc -l` shows 34 and copying text shows no
      toast. If an Omarchy update regenerates the config, re-add the line
- [ ] Default apps (Omarchy ships Chromium and keeps it installed, but the
      laptop uses Chrome):
  - `omarchy default browser chrome`: sets Chrome for links and for
    webapps (`omarchy-launch-webapp` uses the default browser). Check with
    `omarchy-cmd-default-browser` → `google-chrome.desktop`
  - `omarchy default agent claude`
  - `omarchy default terminal ghostty` (switched from foot 2026-11-15 for
    FiraCode ligatures and the ghost animation)
- [ ] **Mouse** (Logitech MX Master 4 via its USB receiver, plugged into
      the KVM). Hand-edit `~/.config/hypr/input.lua` (not stowed: same
      Omarchy-overwrite hazards as `monitors.lua`). Append:
      ```lua
      -- Logitech MX Master 4 (USB receiver via KVM): standard scroll, no acceleration.
      hl.device({ name = "logitech-usb-receiver-mouse", accel_profile = "flat" })
      ```
      The key name matters: a bare `"flat"` (no `accel_profile =`) is a
      silent no-op. **Don't** copy the laptop's `kb_layout = "us-jis"` or
      touchpad block. Scroll stays standard (natural felt inverted on a
      wheel). Check the device name with `hyprctl devices` if the line
      doesn't take
- [ ] Solaar: set the MX4's DPI by feel (laptop testing was at 1600; the
      5120px-wide desk likely wants more). Leave Solaar's scroll
      **Direction** toggles off, since Hyprland owns direction
- [ ] Theme: Tokyo Night (`omarchy-theme-set`)
- [ ] **Chrome UI text size** (tabs, address bar, menus). Chrome on Linux
      takes its UI font from GTK settings, which live in dconf (not
      dotfiles). The laptop has:
      ```
      gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 10'
      gsettings set org.gnome.desktop.interface text-scaling-factor 0.8182
      ```
      (Omarchy doesn't set 0.8182 on this hardware, so it's a manual change.)
      Then fully quit and reopen Chrome. These values were tuned for the
      laptop's 13" panel at scale 2. On the desk monitors, start with the
      same values and adjust `text-scaling-factor` until the tabs look
      right. Note that this also affects other GTK apps' text

## 5. SSH (NAS only) & Claude
GitHub stays on HTTPS through `gh` (Section 4). The SSH key below is only
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

## 6. Networking & NAS
- [ ] `sudo systemctl enable --now tailscaled`, `sudo tailscale up`, then
      approve the node in the admin console. Turn off key expiry for this
      node (it's a server for the AI stack)
- [ ] NAS mount: create `/etc/samba/credentials-nas` by hand
      (`username=`/`password=`, `chmod 600`), add **both** CIFS lines from the
      README (`personal_folder` + `stash`) to `/etc/fstab`,
      `sudo mkdir -p /mnt/nas/senchou /mnt/nas/stash`, then
      `sudo systemctl daemon-reload && sudo systemctl restart remote-fs.target`.
      Check with `ls /mnt/nas/senchou/obsidian-vault /mnt/nas/stash`
- [ ] File-picker bookmarks (not stowed): append to `~/.config/gtk-3.0/bookmarks`
      `file:///mnt/nas/senchou nas` and `file:///mnt/nas/stash stash`
- [ ] Restore `~/.age/` from Vaultwarden/USB (`chmod 700`), and set up `b2`
      auth if you need it on this box
- [ ] Optional: give the desktop a DHCP reservation on the Deco

## 7. Apps & logins
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
- [ ] Obsidian app: open the vault at `/mnt/nas/senchou/obsidian-vault`
      (`obsidian.nvim` already points there via `omarchy/`)
- [ ] Logins: Discord, Cider/Apple Music, Proton, Chrome, Steam, OBS
      settings (re-create scenes by hand)

## 8. Desktop-only: AI host prep
- [ ] **Turn system sleep off** (decided 2026-11-15; revisit once you see
      how much the AI stack gets used remotely). Use the same drop-in
      Omarchy uses on hardware where it disables sleep, so its menus know
      sleep is off. Create `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`
      with:
      ```
      [Sleep]
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
      ```
      Check with `omarchy-sleep-disabled && echo off`. The screen lock and
      screen-off still work as normal. The alternative, if idle power
      matters later, is Wake-on-LAN from the NAS
- [ ] **GPU memory limit (GTT).** By default the GPU can borrow about half
      of RAM (~32GB). Check first: `sudo dmesg | grep -i 'gtt'` shows the
      current size. To allow ~48GB, add the kernel options
      `ttm.pages_limit=12582912 ttm.page_pool_size=12582912` (48GB in 4KB
      pages) to the limine cmdline (`/etc/default/limine`, then
      `sudo limine-update`), reboot, and re-check dmesg.
      `amdgpu.gttsize` is the old, deprecated way. Verify the exact steps on
      the box before applying
- [ ] Firewall is **ufw** on Omarchy (not firewalld). Open the AI ports on
      Tailscale only, e.g.
      `sudo ufw allow in on tailscale0 to any port 5001 proto tcp` (KoboldCpp)
      and `7801` (SwarmUI). Never port-forward on the router
- [ ] KoboldCpp + SwarmUI bring-up per `project_local_ai_stack`. That's a
      separate session once everything above is done

## 9. Project reconnects
- [ ] Strava dashboard, media downloader, ghost animation: pull from
      `scripts`/dotfiles and re-check the NAS paths. Recreate any `.venv`
      with `uv venv` / `sv`
- [ ] photo-badge (cloned in Section 4): `pipx install platformio` (plus
      `clang llvm`). The first `pio run` rebuilds `.pio/` (~98MB of
      toolchains, gitignored). Flashing goes through `/dev/ttyACM0`, so add
      yourself to `uucp` if it isn't already set (the laptop has it)
- [ ] `stream`: check that streamlink plays through mpv (`omarchy/` stows
      `streamlink/config`)
- [ ] mGBA saves via Syncthing. The NAS is the hub
      (`https://sync.tail90599c.ts.net`, login in Vaultwarden "Syncthing – NAS"),
      and each machine keeps a local copy in `~/Games/gba`. **Never play off
      `/mnt/nas`.**
  - [ ] `systemctl --user enable --now syncthing`, then open
        http://127.0.0.1:8384
  - [ ] Settings → Connections: Listen Addresses `tcp://0.0.0.0:22000`,
        untick NAT traversal, Global Discovery, Local Discovery and Relaying
        (tailnet-only, same as the laptop)
  - [ ] Pair: NAS UI → Actions → Show ID. Desktop UI → Add Remote Device,
        name `nas`, Advanced → Addresses `tcp://sync.tail90599c.ts.net:22000`.
        Accept the prompt on the NAS as `desktop` (address `dynamic`)
  - [ ] NAS UI → `gba` folder → Edit → Sharing → tick `desktop`. On the
        desktop, accept it with Folder Path **`~/Games/gba`** (not the
        default `~/gba`). Wait for Up to Date, and check that
        `eza -T ~/Games/gba` shows `pokemon/` (no `_archive`, which is
        NAS-only)
  - [ ] **Before the first launch, close mGBA on the laptop**, and play on
        only one machine at a time. Quit with File → Exit, never Ctrl+C
  - [ ] mGBA: Tools → Settings → Audio/Video → Display driver →
        **Software (Qt)**, then restart. The OpenGL driver spams
        `Attempted flush to non-raster surface` on Qt5/Wayland
  - [ ] Test: open a run with
        `mgba-qt ~/Games/gba/pokemon/<run>/<run>.gba`, check that Continue
        shows the latest progress, save, quit, and confirm the laptop
        receives the new `.sav`

## Not needed on Linux
`amdcleanuputility`, `driverfusionfreesetup`, AMD Adrenalin, UGREEN NAS
Windows client, Docker Desktop, `bm-14.1.0.exe` (BenchMate, a Windows-only
benchmark validator; Section 2 covers burn-in instead).

## Unresolved
- [x] Shipping: arrived 2026-11-19

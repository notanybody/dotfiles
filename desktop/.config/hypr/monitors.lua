-- Framework Desktop: two Gigabytes through the iDock B10 KVM.
-- Stowed from dotfiles desktop/. Edit THIS file (it's a link into the repo).
-- Don't use Omarchy's monitor-scaling menu: it replaces the link with a plain file.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported modes with: hyprctl monitors all

-- GTK only honors whole numbers. 1 keeps XWayland apps sharp
-- (they may look small on the 4K screen, which is expected).
local omarchy_gdk_scale = 1
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Both screens are 2560x1440 *logical* (4K / 1.5 = 1440p), so the shared
-- edge lines up exactly and the mouse doesn't jump crossing over.
-- Match by description, not connector: connector names can change through
-- the KVM. Fill in the exact text from `hyprctl monitors all` on first boot.

-- M27UA: 27" 4K, DisplayPort, left
hl.monitor({ output = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M27UA 24240B007293", mode = "3840x2160@160", position = "0x0", scale = 1.5 })

-- M27Q: 27" 1440p, HDMI, right. Never use its 3840x2160 mode (it downscales; text gets soft)
hl.monitor({ output = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M27Q 0x01010101", mode = "2560x1440@143.86", position = "2560x0", scale = 1 })

-- Fallback for anything else plugged in later
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

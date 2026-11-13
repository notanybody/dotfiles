-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

hl.unbind("SUPER + SHIFT + D")
o.bind("SUPER + SHIFT + D", "Discord" , "omarchy-launch-or-focus-webapp chrome-discord https://discord.com/app")

hl.unbind("SUPER + SHIFT + L")
o.bind("SUPER + SHIFT + L", "Linkding", "omarchy-launch-or-focus-webapp chrome-linkding https://linkding.tail90599c.ts.net")

hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Actual Budget", "omarchy-launch-or-focus-webapp chrome-actual https://actual.tail90599c.ts.net")

hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "Ghostfolio", "omarchy-launch-or-focus-webapp chrome-ghostfolio https://ghostfolio.tail90599c.ts.net")

hl.unbind("SUPER + SHIFT + P")
o.bind("SUPER + SHIFT + P", "Proton Mail", "omarchy-launch-or-focus-webapp chrome-mail https://mail.proton.me")

-- Strata file manager (replaces Nautilus). Full path: ~/.local/bin may not be on Hyprland's PATH.
local strata = os.getenv("HOME") .. "/.local/bin/strata"
o.rebind("SUPER + SHIFT + F", "File manager", { launch = strata })
o.rebind("SUPER + ALT + SHIFT + F", "File manager (cwd)", "uwsm-app -- " .. strata .. ' "$(omarchy-cmd-terminal-cwd)"')

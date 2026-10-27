-- Options are automatically loaded before lazy.nvim startup.
-- NAS is only reached over SSH: copy to the laptop clipboard via OSC 52.
-- Paste reads this Neovim's last copy instead of querying the terminal, which
-- can block for seconds; use terminal paste (Ctrl+Shift+V) for laptop text.
local osc52 = require("vim.ui.clipboard.osc52")
local last_copy = {}

local function copy(register)
  local emit = osc52.copy(register)
  return function(lines, regtype)
    last_copy[register] = { vim.deepcopy(lines), regtype }
    emit(lines)
  end
end

local function paste(register)
  return function()
    return vim.deepcopy(last_copy[register] or { {}, "v" })
  end
end

vim.g.clipboard = {
  name = "OSC 52 (copy only)",
  copy = { ["+"] = copy("+"), ["*"] = copy("*") },
  paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  cache_enabled = 0,
}
-- LazyVim clears this over SSH; turn it back on so plain y/p use the clipboard.
vim.opt.clipboard = "unnamedplus"

-- Match the laptop: no format-on-save.
vim.g.autoformat = false

-- No Python/Node/Perl/Ruby plugins are used; skip the provider checks.
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

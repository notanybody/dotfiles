# NAS zsh: mirrors zsh/.zshrc minus Omarchy toolkit + mise.
# Entered via `exec zsh` from ~/.bashrc (ssh gives non-login bash).
# Never stow nas/ on the laptop.

# PATH first, so starship/zoxide/fzf/eza in ~/.local/bin are found
export PATH="$HOME/.local/bin:$PATH"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt share_history

# Completion
autoload -Uz compinit && compinit -C

# Zap
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-autosuggestions"

# Aliases (shared file, linked by hand like on the laptop)
source ~/.config/zsh/aliases.zsh

# bat/man look (from omarchy.zsh)
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# fzf
eval "$(fzf --zsh)"

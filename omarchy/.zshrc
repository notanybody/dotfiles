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

# Aliases
source ~/.config/zsh/aliases.zsh

# Omarchy default toolkit (ported from bash - see comment at top of the file)
source ~/.config/zsh/omarchy.zsh

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# fzf
eval "$(fzf --zsh)"

# Mise
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"

# Fastfetch
fastfetch

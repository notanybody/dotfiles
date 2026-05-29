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

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# fzf 
eval "$(fzf --zsh)"

# Mise
export PATH="$HOME/.local/bin:$PATH"
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(mise activate zsh)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

# Scripts
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/scripts:$PATH"

# Fastfetch
fastfetch

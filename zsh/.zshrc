# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt share_history

# Completion
autoload -Uz compinit && compinit

# Syntax Highlighting
if [[ "$OSTYPE" == "darwin"* ]]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Aliases
source ~/.config/zsh/aliases.zsh

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# fzf 
eval "$(fzf --zsh)"

# Mise
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(mise activate zsh)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

# Fastfetch
fastfetch

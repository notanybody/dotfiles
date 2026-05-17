# History
  HISTSIZE=10000
  SAVEHIST=10000
  HISTFILE=~/.zsh_history
  setopt share_history

  # Completion
  autoload -Uz compinit && compinit

  # Syntax highlighting
  source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Aliases
  source ~/.config/zsh/aliases.zsh

  # Starship
  eval "$(starship init zsh)"

  # Zoxide
  eval "$(zoxide init zsh)"

  # Mise
  eval "$(~/.local/bin/mise activate zsh)"

  # Fastfetch
  fastfetch

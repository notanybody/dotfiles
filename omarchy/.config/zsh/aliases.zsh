# Aliases
#
# --- Shared ---
# eza Aliases
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons'

# Alias Config + GitHub Push
alias za='nvim ~/.config/zsh/aliases.zsh'
alias zar='source ~/.config/zsh/aliases.zsh'
alias dotfiles='cd ~/Projects/dotfiles'
alias gp='git add . && git commit && git push'
alias gl='git pull'
alias sv='source .venv/bin/activate'
export EDITOR=nvim

# FZF Tokyo Night Storm Theme
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --highlight-line \
    --info=inline-right \
    --ansi \
    --layout=reverse \
    --border=none \
    --color=bg+:#2e3c64 \
    --color=bg:#1f2335 \
    --color=fg:#c0caf5 \
    --color=gutter:#1f2335 \
    --color=header:#ff9e64 \
    --color=hl+:#2ac3de \
    --color=hl:#2ac3de \
    --color=info:#545c7e \
    --color=marker:#ff007c \
    --color=pointer:#ff007c \
    --color=prompt:#2ac3de \
    --color=query:#c0caf5:regular \
    --color=scrollbar:#29a4bd \
    --color=separator:#ff9e64 \
    --color=spinner:#ff007c \
  "

# Aliases
alias cw='cd /mnt/c/users/jackw'
alias desktop='cd /mnt/c/users/jackw/Desktop'
alias downloads='cd /mnt/c/users/jackw/Downloads'
alias jdrive='cd /mnt/j'
alias psconfig='nvim /mnt/c/users/jackw/OneDrive/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
alias omza='nvim ~/.config/zsh/aliases.zsh'
alias omza-r='source ~/.config/zsh/aliases.zsh'
alias cat='batcat'
alias dotfiles='cd /home/jackw/dotfiles/'
alias dotsync='cd /home/jackw/dotfiles/ && git add . && git commit -m "update dotfiles" && git push'
alias nvfs='selected=$(fzf -m --preview="batcat --color=always --style=numbers {}") && [ -n "$selected" ] && nvim $selected'

#eza aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'

# Startup
cd /mnt/c/users/jackw

#Starship
eval "$(starship init zsh)"

#zoxide
eval "$(zoxide init zsh)"

#yazi
export PATH=$PATH:/snap/bin

#mise
eval "$(~/.local/bin/mise activate zsh)"

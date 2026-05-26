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
alias dotfiles='cd ~/dotfiles'
alias gp='git add . && git commit && git push'
alias gl='git pull'

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
# Mac Functions
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias cat='bat'
  alias nvfs='selected=$(fzf -m --preview="bat --color=always --style=numbers {}") && [ -n "$selected" ] && nvim $selected'

 #Streamlink Recording
  function record() {
      streamlink "twitch.tv/$1" "${2:-best}" --record "/Volumes/personal_folder/twitch-recordings/${1}_$(date +%Y%m%d_%H%M%S).mkv"
    }

 #YouTube Downloads
  function ytdl() {
      yt-dlp "$1" --merge-output-format mp4 --restrict-filenames -o "/Volumes/personal_folder/youtube-downloads/%(title)s_$(date +%Y%m%d).%(ext)s"
    }

 #Organize Downloads on NAS
  function organize-downloads() {
      for file in /Volumes/personal_folder/youtube-downloads/*.mp4; do
        date=$(echo "$file" | grep -oE '[0-9]{8}' | tail -1)
        if [[ -n "$date" ]]; then
          year=${date:0:4}
          month=${date:4:2}
          dest="/Volumes/personal_folder/youtube-downloads/$year/$month"
          mkdir -p "$dest"
          mv "$file" "$dest/"
          echo "Moved $(basename $file) -> $year/$month/"
        fi
      done
    }

# WSL Ubuntu Functions 
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias cw='cd /mnt/c/users/jackw'
  alias desktop='cd /mnt/c/users/jackw/Desktop'
  alias downloads='cd /mnt/c/users/jackw/Downloads'
  alias jdrive='cd /mnt/j'
  alias sdrive='cd /mnt/s'
  alias wincommands='nvim /mnt/c/users/jackw/OneDrive/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
  alias psconfig='nvim /mnt/c/Users/jackw/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
  alias cat='batcat'
  alias nvfs='selected=$(fzf -m --preview="batcat --color=always --style=numbers {}") && [ -n "$selected" ] && nvim $selected'
  export PATH=$PATH:/snap/bin
  export PATH=$PATH:~/scripts/
  export EDITOR=nvim

fi

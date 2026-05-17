# Aliases
#
# --- Shared ---
# eza Aliases
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons'

# Alias Config + GitHub Push
alias omza='nvim ~/.config/zsh/aliases.zsh'
alias omza-r='source ~/.config/zsh/aliases.zsh'
alias dotfiles='cd ~/dotfiles'
alias dotsync='cd ~/dotfiles && git add . && git commit -m "update dotfiles" && git push'

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
  alias psconfig='nvim /mnt/c/users/jackw/OneDrive/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
  alias cat='batcat'
  alias nvfs='selected=$(fzf -m --preview="batcat --color=always --style=numbers {}") && [ -n "$selected" ] && nvim $selected'
  export PATH=$PATH:/snap/bin

  # Startup
  cd /mnt/c/users/jackw
fi

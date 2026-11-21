# Aliases
#
# --- Shared ---
# eza Aliases
alias ls='eza --icons=auto'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons=auto'
alias hashcat='hashcat --hwmon-temp-abort=97'

# Alias Config + GitHub Push
alias za='nvim ~/.config/zsh/aliases.zsh'
alias zar='source ~/.config/zsh/aliases.zsh'
alias gl='git pull --rebase --autostash'
alias sv='source .venv/bin/activate'
export EDITOR=nvim

# Stage + commit (skipped if nothing staged), rebase on remote, push
unalias gp 2>/dev/null
gp() {
  git add . &&
  { git diff --cached --quiet || git commit; } &&
  git pull --rebase &&
  git push
}

# mdv: rendered Markdown (glow) inside bat's frame (header, grid, line numbers, pager)
# Line numbers count rendered lines, not source lines. Needs glow + bat.
mdv() {
  glow -s tokyo-night -w $(( COLUMNS - 10 )) "$1" \
    | bat --style=header-filename,grid,numbers --file-name "$1"
}

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

# --- hashcat helpers (shared) ---
# Decode a hex string to text, e.g. the SSID-hex (field 6) of a .22000 capture.
unhex() { printf '%b\n' "$(sed 's/../\\x&/g' <<< "$1")"; }

# Read a cracked WPA result from a .22000 file: network name + password.
# SSID comes from field 6 of the file; password from the potfile via --show.
# Usage: wparesult ~/wordlists/mine.22000
pwnwrk() {
  local ssid pw
  ssid=$(printf '%b' "$(cut -d'*' -f6 "$1" | head -1 | sed 's/../\\x&/g')")
  pw=$(hashcat -m 22000 "$1" --show 2>/dev/null | cut -d: -f2-)
  printf 'SSID:     %s\nPassword: %s\n' "$ssid" "${pw:-<not cracked yet>}"
}

# --- Platform Setup ---
# Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  NAS_ROOT="/Volumes/personal_folder"
  SCRIPTS=~/scripts
  alias cat='bat'

# WSL Ubuntu
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  alias cw='cd /mnt/c/users/jackw'
  alias desktop='cd /mnt/c/users/jackw/Desktop'
  alias downloads='cd /mnt/c/users/jackw/Downloads'
  alias jdrive='cd /mnt/j'
  alias sdrive='cd /mnt/s'
  alias wincommands='nvim /mnt/c/users/jackw/OneDrive/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
  alias psconfig='nvim /mnt/c/Users/jackw/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'
  SCRIPTS=~/scripts
  alias cat='batcat'
  export PATH=$PATH:/snap/bin
  export PATH=$PATH:$SCRIPTS

# UGREEN NAS (bat = ~/.local/bin/bat -> batcat)
elif [[ -d /volume1 ]]; then
  alias cat='bat'

# Linux (Omarchy)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  NAS_ROOT="/mnt/nas/senchou"
  SCRIPTS=~/Projects/scripts

  # cat: bat for everything, but one .md file shown in a terminal renders via mdv.
  # Pipes/redirects (-t 1 false) stay raw. Raw Markdown on screen: bat file.md
  # `function cat {` (not `cat() {`): zsh parses this whole if-block before
  # running it, so an old `cat` alias would otherwise expand on `zar` re-source.
  unalias cat 2>/dev/null
  function cat {
    if [[ $# -eq 1 && "$1" == *.md && -f "$1" && -t 1 ]] && (( $+commands[glow] )); then
      mdv "$1"
    else
      bat "$@"
    fi
  }
fi

# --- NAS Functions (only where the NAS is mounted) ---
if [[ -n "$NAS_ROOT" ]]; then

  # Streamlink Recording
  function record() {
    streamlink "twitch.tv/$1" "${2:-best}" --record "$NAS_ROOT/twitch-recordings/${1}_$(date +%Y%m%d_%H%M%S).mkv"
  }

  # YouTube Downloads
  function ytdl() {
    yt-dlp "$1" --merge-output-format mp4 --restrict-filenames -o "$NAS_ROOT/youtube-downloads/%(title)s_$(date +%Y%m%d).%(ext)s"
  }

  # Organize YouTube downloads into YYYY/MM
  function organize-downloads() {
    local root="$NAS_ROOT/youtube-downloads"
    for file in "$root"/*.mp4(N); do
      local name=$(basename "$file")
      local date=$(echo "$name" | grep -oE '[0-9]{8}' | tail -1)
      if [[ -n "$date" ]]; then
        local dest="$root/${date:0:4}/${date:4:2}"
        mkdir -p "$dest"
        mv -n "$file" "$dest/"
        echo "Moved $name -> ${date:0:4}/${date:4:2}/"
      fi
    done
  }

  # Organize Twitch recordings into channel/YYYY/MM
  function organize-twitch() {
    local root="$NAS_ROOT/twitch-recordings"
    for file in "$root"/*.{mkv,ts,txt}(N); do
      local name=$(basename "$file")
      local channel=${name%%_*}
      local date=$(echo "$name" | grep -oE '_[0-9]{8}_' | tr -d '_')
      if [[ -n "$date" ]]; then
        local dest="$root/$channel/${date:0:4}/${date:4:2}"
        mkdir -p "$dest"
        mv -n "$file" "$dest/"
        echo "Moved $name -> $channel/${date:0:4}/${date:4:2}/"
      fi
    done
  }

  # Process incoming OF4LM/FAP4LM downloads into the onlyfans library
  function organize-incoming() {
    python3 "$SCRIPTS/organize/nas/process_incoming.py" "$NAS_ROOT/division/incoming" "$NAS_ROOT/division/onlyfans" "$@"
  }
  
fi

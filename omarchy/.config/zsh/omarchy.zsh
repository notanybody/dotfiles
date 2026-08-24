# Omarchy's default bash toolkit, ported to zsh.
#
# Omarchy only auto-sources this stuff into bash (/etc/skel/.bashrc ->
# $OMARCHY_PATH/default/bash/rc). Since this shell is zsh, none of it loads
# on its own — so the manual's tdl/tds/etc. and the a/c/cx/cy/d/r/t/h
# shortcuts are ported here by hand. Source of truth stays at
# $OMARCHY_PATH/default/bash/{envs,aliases,fns/*}; re-running `omarchy
# refresh` upstream won't touch this file, so re-diff after a big
# `omarchy update` if things feel out of sync.
#
# ls/lt/lsa/lta are intentionally skipped -- the dotfiles eza aliases win.

: "${OMARCHY_PATH:=/usr/share/omarchy}"

# --- envs (bash/envs) ---
export EDITOR="${EDITOR:-omarchy-launch-editor --inline}"
export SUDO_EDITOR="$EDITOR"
export BROWSER="${BROWSER:-omarchy-launch-browser}"
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

if [ -z "${LANG:-}" ]; then
  [ -r /etc/locale.conf ] && . /etc/locale.conf
  LANG="${LANG:-C.UTF-8}"
  export LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY \
    LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT \
    LC_IDENTIFICATION
fi

# Command hashing off, so mise's version-switching shims re-resolve (mirrors
# bash's `set +h`).
unsetopt hashcmds

# --- aliases (bash/aliases) ---
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi
alias eff='$EDITOR "$(ff)"'
sff() { if [ $# -eq 0 ]; then echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1; fi; local file; file=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) && [ -n "$file" ] && scp "$file" "$1"; }

if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi

      printf "\U000F17A9 "
      pwd
    fi
  }
fi

open() (
  xdg-open "$@" >/dev/null 2>&1 &
)

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
alias cy='codex -s danger-full-access -a never'
alias d='docker'
alias r='rails'
alias t='tmux attach || tmux new -s Work'
alias h='herdr'
alias ic='tdl c'
alias ix='tdl cx'
alias icx='tdl c cx'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# --- functions (bash/fns/*): tdl/tds/tdlm/tsl, hdl/hds/hdlm/hsl, compress/
# decompress, iso2sd/format-drive, rsw/lsw/dsw, fip/dip/lip, ssh wrapper, ga/gd ---
for f in "$OMARCHY_PATH"/default/bash/fns/*; do
  source "$f"
done

# tsl() and hsl() index arrays the bash way (0-based, e.g. ${panes[0]}); zsh
# arrays are 1-based by default. Force ksh-style (0-based) array semantics
# for just these two function bodies so they behave the way they were
# written, without touching zsh's array indexing anywhere else.
functions[tsl]="emulate -L ksh
${functions[tsl]}"
functions[hsl]="emulate -L ksh
${functions[hsl]}"

# --- omarchy CLI tab-completion (bash/completions), via zsh's bash-compat shim ---
autoload -U +X bashcompinit && bashcompinit
source "$OMARCHY_PATH/default/bash/completions"

# --- try tool activation (bash/init) ---
if command -v try &> /dev/null; then
  try() {
    unset -f try
    eval "$(SHELL=/bin/bash command try init ~/Work/tries)"
    try "$@"
  }
fi

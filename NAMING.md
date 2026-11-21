# File Naming Convention

Set 2026-11-20. Based on ISO 8601 (dates) and the POSIX portable filename
character set, with exceptions where Linux/tool conventions win.

## Rules

### 1. Characters

- Only `a-z 0-9 . _ -` — lowercase, no spaces, no `& ' ( ) :` or accents.
- Never start with `-` (gets parsed as a flag).
- Only start with `.` when the file should be hidden.
- Never rely on case to distinguish names — the NAS (SMB) and macOS are
  case-insensitive.

### 2. Separators

| Char | Job | Example |
|------|-----|---------|
| `-`  | joins words within a field | `nas-backup`, `okayu-xmas` |
| `_`  | separates fields | `2026-11-20_nas-backup_v02.log` |
| `.`  | before the extension only | `.tar.gz` ok, `my.notes.md` not |

### 3. Field order

General → specific, date first so `ls` sorts chronologically:

```
<date>_<subject>_<detail>_<version>.<ext>
```

```
2026-11-20_parents-server_build-notes_v03.md
2026-11-20_strava_export.csv
2026-11_actual-budget_statement.pdf
```

Only use the fields that apply.

### 4. Dates and times (ISO 8601)

| Precision | Format | Example |
|-----------|--------|---------|
| Day   | `YYYY-MM-DD`       | `2026-11-20` |
| Month | `YYYY-MM`          | `2026-11` |
| Year  | `YYYY`             | `2026` |
| Time  | `YYYY-MM-DDTHHMM`  | `2026-11-20T1430` |

No colons in times — they break on SMB, Windows and macOS Finder.

### 5. Versions

- Zero-padded: `v01`, `v02` … `v10` (sorts correctly).
- Never `final`, `final2`, `new`, `old`.
- Files in git don't get versions — git is the version.

### 6. Extensions

- Lowercase: `.jpg` not `.JPG`.
- YAML is **always `.yml`**, never `.yaml` (unless an app requires it).
- Executables in `~/.local/bin` get **no extension**.

## Exceptions

| Thing | Convention | Example |
|-------|------------|---------|
| Home directories | Keep XDG/Omarchy defaults | `~/Documents`, `~/Projects` |
| Python modules | `snake_case` (PEP 8, importable) | `process_incoming.py` |
| Shell commands | `kebab-case`, no extension | `update-stacks`, `wallcheck` |
| Standard project files | Canonical names | `README.md`, `LICENSE`, `Makefile`, `Dockerfile`, `compose.yml`, `.env` |
| App config | Whatever the app expects | `~/.config/hypr/hyprland.conf` |
| App-managed libraries | **Never rename** | Immich, Stash, camera `IMG_20261120_143000.jpg` |

## Renaming tools

Always dry-run first.

```sh
fd -e yaml .                          # find files to fix
perl-rename -n 's/\.yaml$/.yml/' *    # preview (-n), drop -n to apply
detox -n <dir>                        # preview cleaning spaces/junk chars
vimv                                  # rename files in $EDITOR
```
